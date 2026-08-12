--SDロボ・ライオ
-- 效果：
-- 这张卡召唤成功时，可以从手卡把1只名字带有「超级防卫机器人」的怪兽或者「轨道 7」特殊召唤。此外，1回合1次，从自己墓地有名字带有「超级防卫机器人」的怪兽或者「轨道 7」1只加入自己手卡时，可以把那只怪兽从手卡特殊召唤。
function c8091563.initial_effect(c)
	-- 这张卡召唤成功时，可以从手卡把1只名字带有「超级防卫机器人」的怪兽或者「轨道 7」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(8091563,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c8091563.sumtg)
	e1:SetOperation(c8091563.sumop)
	c:RegisterEffect(e1)
	-- 此外，1回合1次，从自己墓地有名字带有「超级防卫机器人」的怪兽或者「轨道 7」1只加入自己手卡时，可以把那只怪兽从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(8091563,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetCountLimit(1)
	e2:SetCondition(c8091563.spcon)
	e2:SetTarget(c8091563.sptg)
	e2:SetOperation(c8091563.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：手卡中名字带有「超级防卫机器人」的怪兽或者「轨道 7」且可以特殊召唤的卡
function c8091563.filter(c,e,tp)
	return (c:IsSetCard(0x85) or c:IsCode(71071546)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 召唤成功时效果的发动准备与检查函数
function c8091563.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在满足过滤条件的卡
		and Duel.IsExistingMatchingCard(c8091563.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息：从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 召唤成功时效果的执行函数
function c8091563.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则返回
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c8091563.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 墓地卡片加入手卡时效果的发动条件检查函数
function c8091563.spcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return eg:GetCount()==1 and (tc:IsSetCard(0x85) or tc:IsCode(71071546))
		and tc:IsControler(tp) and tc:IsPreviousControler(tp) and tc:IsPreviousLocation(LOCATION_GRAVE)
end
-- 墓地卡片加入手卡时效果的发动准备与检查函数
function c8091563.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and eg:GetFirst():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将加入手卡的卡设为效果处理的对象
	Duel.SetTargetCard(eg)
	-- 设置连锁处理的操作信息：特殊召唤该对象卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,eg,1,0,0)
end
-- 墓地卡片加入手卡时效果的执行函数
function c8091563.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
