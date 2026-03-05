--ピュアリィ・スリーピィメモリー
-- 效果：
-- ①：这个回合，自己受到的战斗·效果伤害只有1次变成0。并且，可以再让以下效果适用。
-- ●选自己1张手卡丢弃，从卡组把1只1星「纯爱妖精」怪兽特殊召唤。
-- ②：持有这张卡作为素材中的「纯爱妖精」超量怪兽得到以下效果。
-- ●对方准备阶段才能发动。自己从卡组抽1张。
local s,id,o=GetID()
-- 注册卡的效果，包括①效果的发动和②效果的触发
function s.initial_effect(c)
	-- ①：这个回合，自己受到的战斗·效果伤害只有1次变成0。并且，可以再让以下效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	-- ②：持有这张卡作为素材中的「纯爱妖精」超量怪兽得到以下效果。
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
-- 定义过滤函数，用于筛选1星纯爱妖精怪兽
function s.filter(c,e,tp)
	return c:IsLevel(1) and c:IsSetCard(0x18c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的处理函数，设置伤害减免和特殊召唤条件
function s.op(e,tp,eg,ep,ev,re,r,rp)
	-- ①：这个回合，自己受到的战斗·效果伤害只有1次变成0。并且，可以再让以下效果适用。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetCondition(s.damcon)
	e1:SetValue(s.damval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册伤害减免效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetValue(1)
	-- 注册伤害无效化效果
	Duel.RegisterEffect(e2,tp)
	-- 检查玩家手牌是否存在可丢弃的卡
	if Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil)
		-- 检查玩家场上是否存在空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家卡组是否存在1星纯爱妖精怪兽
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp)
		-- 询问玩家是否发动特殊召唤效果
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否从卡组特殊召唤？"
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 丢弃1张手牌
		if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)>0 then
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 选择1只1星纯爱妖精怪兽
			local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
			if g:GetCount()>0 then
				-- 将选中的怪兽特殊召唤
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
-- 判断是否已使用过①效果
function s.damcon(e)
	local tp=e:GetHandlerPlayer()
	-- 判断是否已使用过①效果
	return Duel.GetFlagEffect(tp,id)==0
end
-- 设置伤害值为0的效果处理
function s.damval(e,re,val,r,rp,rc)
	local tp=e:GetHandlerPlayer()
	if bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 then
		-- 注册①效果已使用过的标识
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		return 0
	end
	return val
end
-- ②效果的触发条件
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否为纯爱妖精超量怪兽且为对方准备阶段
	return c:IsSetCard(0x18c) and Duel.GetTurnPlayer()==1-tp
end
-- ②效果的发动准备
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 提示对方玩家选择了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置效果的目标玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数
	Duel.SetTargetParam(1)
	-- 设置效果的操作信息为抽卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果的处理函数
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家抽卡
	Duel.Draw(p,d,REASON_EFFECT)
end
