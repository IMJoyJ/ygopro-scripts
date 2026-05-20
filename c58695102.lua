--リ・バイブル
-- 效果：
-- 「再生圣经」的效果1回合只能使用1次。
-- ①：这张卡在墓地存在，自己的额外卡组的数量比对方少5张以上的场合，支付2000基本分才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c58695102.initial_effect(c)
	-- 「再生圣经」的效果1回合只能使用1次。①：这张卡在墓地存在，自己的额外卡组的数量比对方少5张以上的场合，支付2000基本分才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(58695102,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,58695102)
	e1:SetCondition(c58695102.condition)
	e1:SetCost(c58695102.cost)
	e1:SetTarget(c58695102.target)
	e1:SetOperation(c58695102.operation)
	c:RegisterEffect(e1)
end
-- 发动条件：检查自己的额外卡组数量是否比对方少5张以上
function c58695102.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取并比较双方额外卡组的卡片数量，判断自己是否比对方少5张以上
	return Duel.GetFieldGroupCount(tp,LOCATION_EXTRA,0)<=Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)-5
end
-- 发动代价：检查并支付2000基本分
function c58695102.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，确认玩家是否能够支付2000基本分
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	-- 扣除玩家2000基本分作为发动的代价
	Duel.PayLPCost(tp,2000)
end
-- 发动准备：确认怪兽区域有空位且自身可以特殊召唤，并设置特殊召唤的操作信息
function c58695102.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，确认自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 向系统宣告此效果包含特殊召唤分类，且特殊召唤的对象是自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将自身特殊召唤，并为其添加离场时除外的约束效果
function c58695102.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍与效果相关，则将其以表侧表示特殊召唤，并判断特殊召唤是否成功
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
