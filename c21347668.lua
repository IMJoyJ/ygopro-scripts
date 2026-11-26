--ピュアリィ・スリーピィメモリー
-- 效果：
-- ①：这个回合，自己受到的战斗·效果伤害只有1次变成0。并且，可以再让以下效果适用。
-- ●选自己1张手卡丢弃，从卡组把1只1星「纯爱妖精」怪兽特殊召唤。
-- ②：持有这张卡作为素材中的「纯爱妖精」超量怪兽得到以下效果。
-- ●对方准备阶段才能发动。自己从卡组抽1张。
local s,id,o=GetID()
-- 初始化卡片效果：注册①效果（发动免除1次伤害并可选丢弃手卡从卡组特召）以及②效果（作为超量素材赋予「纯爱妖精」超量怪兽的对方准备阶段抽卡效果）
function s.initial_effect(c)
	-- ①：这个回合，自己受到的战斗·效果伤害只有1次变成0。并且，可以再让以下效果适用。 ●选自己1张手卡丢弃，从卡组把1只1星「纯爱妖精」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON+CATEGORY_HANDES_SELF)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	-- ②：持有这张卡作为素材中的「纯爱妖精」超量怪兽得到以下效果。 ●对方准备阶段才能发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"抽1张卡（纯爱妖精瞌睡回忆）"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.drcon)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
-- 筛选条件：检查卡片是否为等级1且可特殊召唤的「纯爱妖精」怪兽
function s.filter(c,e,tp)
	return c:IsLevel(1) and c:IsSetCard(0x18c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的处理流程：为己方注册本回合1次免除战斗·效果伤害的持续效果，之后可选丢弃1张手卡并从卡组特殊召唤1只1星「纯爱妖精」怪兽
function s.op(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，自己受到的战斗·效果伤害只有1次变成0。并且，可以再让以下效果适用。 ●选自己1张手卡丢弃，从卡组把1只1星「纯爱妖精」怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetCondition(s.damcon)
	e1:SetValue(s.damval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为己方玩家注册将受到的战斗或效果伤害变为0的效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetValue(1)
	-- 为己方玩家注册“不受效果伤害”标识效果，用于引擎及相关效果的免伤状态检测
	Duel.RegisterEffect(e2,tp)
	-- 检查己方手卡中是否存在至少1张可丢弃的卡
	if Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil)
		-- 检查己方主要怪兽区是否存在可用空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方卡组中是否存在可特殊召唤的1星「纯爱妖精」怪兽
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp)
		-- 询问己方是否适用丢弃手卡并从卡组特殊召唤的追加效果
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否从卡组特殊召唤？"
		-- 中断效果处理，使后续的丢弃手卡与特殊召唤和前面的免伤效果视为不同时处理
		Duel.BreakEffect()
		-- 让己方选择并丢弃1张手卡，并确认丢弃操作成功
		if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)>0 then
			-- 向己方提示选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 让己方从己方卡组选择1只1星「纯爱妖精」怪兽
			local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
			if g:GetCount()>0 then
				-- 将所选怪兽以表侧表示特殊召唤到己方场上
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
-- 免伤效果生效条件检查：确认己方本回合尚未消耗该1次免伤次数
function s.damcon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查己方玩家是否还没有注册本卡的免伤已使用标识
	return Duel.GetFlagEffect(tp,id)==0
end
-- 伤害数值修改函数：若伤害来源于战斗或效果，则注册本回合已使用标记并将伤害返回为0，否则保持原伤害数值
function s.damval(e,re,val,r,rp,rc)
	local tp=e:GetHandlerPlayer()
	if bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 then
		-- 为己方注册持续至回合结束时的标识效果，标记本回合1次的免伤机会已被使用
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		return 0
	end
	return val
end
-- ②效果的发动条件检查：确认持有此素材的怪兽是「纯爱妖精」怪兽，且当前处于对方回合
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断效果持有者是否为「纯爱妖精」怪兽且当前回合玩家为对方
	return c:IsSetCard(0x18c) and Duel.GetTurnPlayer()==1-tp
end
-- ②效果的发动检测与连锁信息设置：确认己方可以抽1张卡，提示对方并登记抽卡目标与操作信息
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认己方玩家可以执行抽1张卡的操作
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 向对方提示己方选择了该抽卡效果发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 将当前连锁的目标玩家设为己方
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的目标参数（抽卡数量）设为1
	Duel.SetTargetParam(1)
	-- 登记连锁的抽卡操作信息，预计使己方从卡组抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果的处理流程：读取连锁目标玩家与数量并执行抽卡
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得目标玩家与抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果使目标玩家抽1张卡
	Duel.Draw(p,d,REASON_EFFECT)
end
