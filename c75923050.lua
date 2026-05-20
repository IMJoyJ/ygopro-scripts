--レアメタル・ヴァルキリー
-- 效果：
-- 「稀有金属女郎」＋「稀有金属战士」
-- 这张卡在给对方直接攻击的伤害计算时攻击力上升1000，上场上的这张卡可以和融合区的「稀有金属骑士」互换（这张卡特殊召唤的回合不可以互换。）
function c75923050.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置「稀有金属女郎」和「稀有金属战士」作为融合素材的融合召唤手续
	aux.AddFusionProcCode2(c,92421852,38916461,true,true)
	-- 这张卡在给对方直接攻击的伤害计算时攻击力上升1000
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75923050,0))  --"攻击上升"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c75923050.atkcon)
	e1:SetValue(1000)
	c:RegisterEffect(e1)
	-- 上场上的这张卡可以和融合区的「稀有金属骑士」互换（这张卡特殊召唤的回合不可以互换。）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(75923050,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c75923050.spcon)
	e2:SetTarget(c75923050.sptg)
	e2:SetOperation(c75923050.spop)
	c:RegisterEffect(e2)
end
-- 判定是否处于给对方直接攻击的伤害计算时
function c75923050.atkcon(e)
	-- 获取当前的决斗阶段
	local ph=Duel.GetCurrentPhase()
	if not (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL) then return false end
	-- 获取当前进行攻击的怪兽
	local a=Duel.GetAttacker()
	-- 获取当前被攻击的怪兽
	local d=Duel.GetAttackTarget()
	return a==e:GetHandler() and d==nil
end
-- 判定自身是否不在特殊召唤的回合
function c75923050.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定自身特殊召唤的回合数是否不等于当前回合数
	return e:GetHandler():GetTurnID()~=Duel.GetTurnCount()
end
-- 过滤额外卡组中可以特殊召唤的「稀有金属骑士」
function c75923050.spfilter(c,e,tp,mc)
	-- 判定卡片是否为「稀有金属骑士」、能否特殊召唤，以及额外怪兽区域是否有可用空位
	return c:IsCode(1412158) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 互换效果的发动准备，检查自身是否能回到额外卡组以及额外卡组是否有可特殊召唤的「稀有金属骑士」
function c75923050.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToExtra()
		-- 检查额外卡组是否存在至少1张满足特殊召唤条件的「稀有金属骑士」
		and Duel.IsExistingMatchingCard(c75923050.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
	-- 设置操作信息：将自身送回额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 互换效果的执行函数，将自身送回额外卡组并特殊召唤「稀有金属骑士」
function c75923050.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 获取额外卡组中第1张满足特殊召唤条件的「稀有金属骑士」
		local tc=Duel.GetFirstMatchingCard(c75923050.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,c)
		-- 若存在目标卡，则将自身送回额外卡组并洗牌，且判定是否成功送回
		if tc and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
			-- 将选中的「稀有金属骑士」表侧表示特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
