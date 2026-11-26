--WW－アイス・ベル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上没有怪兽存在的场合才能发动。这张卡从手卡特殊召唤。那之后，可以从卡组把1只「风魔女」怪兽特殊召唤。这个效果从卡组特殊召唤的怪兽不能解放，这个效果发动的回合，自己不是5星以上的风属性怪兽不能从额外卡组特殊召唤。
-- ②：这张卡召唤·特殊召唤成功的场合才能发动。给与对方500伤害。
function c43722862.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己场上没有怪兽存在的场合才能发动。这张卡从手卡特殊召唤。那之后，可以从卡组把1只「风魔女」怪兽特殊召唤。这个效果从卡组特殊召唤的怪兽不能解放，这个效果发动的回合，自己不是5星以上的风属性怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43722862,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,43722862)
	e1:SetCondition(c43722862.spcon)
	e1:SetCost(c43722862.spcost)
	e1:SetTarget(c43722862.sptg)
	e1:SetOperation(c43722862.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：这张卡召唤·特殊召唤成功的场合才能发动。给与对方500伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43722862,2))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,43722863)
	e2:SetTarget(c43722862.damtg)
	e2:SetOperation(c43722862.damop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- 注册特殊召唤活动计数器，追踪本回合是否曾从额外卡组特召过非5星以上风属性的怪兽
	Duel.AddCustomActivityCounter(43722862,ACTIVITY_SPSUMMON,c43722862.counterfilter)
end
-- 计数器过滤函数：若并非从额外卡组召唤，或为表侧表示的5星以上风属性怪兽则返回true（不触发计数）
function c43722862.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or (c:IsLevelAbove(5) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsFaceup())
end
-- 检查①效果发动条件：己方怪兽区没有怪兽存在
function c43722862.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断己方怪兽区的怪兽数量是否为0
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 检查并施加①效果誓约：确认本回合此前未违反自肃，并注册本回合禁止从额外卡组特召5星以上风属性以外怪兽的限制
function c43722862.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前确认本回合尚未从额外卡组特殊召唤过非5星以上风属性怪兽
	if chk==0 then return Duel.GetCustomActivityCount(43722862,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个效果发动的回合，自己不是5星以上的风属性怪兽不能从额外卡组特殊召唤。这张卡从手卡特殊召唤。那之后，可以从卡组把1只「风魔女」怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c43722862.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为己方玩家注册持续至回合结束的额外卡组特殊召唤自肃效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件函数：阻止从额外卡组特殊召唤等级5以上风属性以外的怪兽
function c43722862.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not (c:IsLevelAbove(5) and c:IsAttribute(ATTRIBUTE_WIND)) and c:IsLocation(LOCATION_EXTRA)
end
-- 发动前确认己方怪兽区有空位且手卡的此卡可以特殊召唤
function c43722862.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方怪兽区是否至少有1个可用空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记将此卡自身特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤卡组中可特殊召唤的「风魔女」怪兽
function c43722862.spfilter(c,e,tp)
	return c:IsSetCard(0xf0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果处理：特召手卡的此卡后，若场上仍有空位且卡组有「风魔女」怪兽，可选择其中1只特殊召唤并赋予其不能作为任何目的解放的限制
function c43722862.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将手卡的此卡以表侧表示特殊召唤到己方场上，并判断是否召唤成功
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 若己方怪兽区已无剩余空位则结束处理
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 从己方卡组检索所有可特殊召唤的「风魔女」怪兽
		local g=Duel.GetMatchingGroup(c43722862.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 若卡组存在可特召的「风魔女」怪兽，询问玩家是否从卡组特殊召唤
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(43722862,1)) then  --"是否从卡组把1只「风魔女」怪兽特殊召唤？"
			-- 插入效果处理间断，使自身特召与卡组特召视为不同时处理
			Duel.BreakEffect()
			-- 向己方发送从卡组选择要特殊召唤的「风魔女」怪兽的提示
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			local tc=sg:GetFirst()
			if tc then
				-- 将选中的「风魔女」怪兽以表侧表示特殊召唤到己方场上
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
				-- 这个效果从卡组特殊召唤的怪兽不能解放，
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UNRELEASABLE_SUM)
				e1:SetValue(1)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
				-- 这个效果从卡组特殊召唤的怪兽不能解放，
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
				e2:SetValue(1)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e2)
			end
		end
	end
end
-- 发动前设置②效果的目标玩家为对方、伤害数值为500并登记伤害操作信息
function c43722862.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前连锁的伤害数值参数为500
	Duel.SetTargetParam(500)
	-- 登记给予对方500点效果伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- ②效果处理：读取连锁设定的目标玩家和伤害数值，给予对方500点效果伤害
function c43722862.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 读取当前连锁设定的目标玩家p和伤害数值d
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家p造成d点效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
