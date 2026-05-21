--ヴァイロン・エレメント
-- 效果：
-- 自己场上表侧表示存在的名字带有「大日」的装备卡被破坏时，可以从自己卡组把最多和破坏数量相同数量的名字带有「大日」的调整在自己场上特殊召唤。把这个效果特殊召唤的怪兽作为同调素材的场合，不是名字带有「大日」的怪兽的同调召唤不能使用。
function c92035412.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己场上表侧表示存在的名字带有「大日」的装备卡被破坏时，可以从自己卡组把最多和破坏数量相同数量的名字带有「大日」的调整在自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(92035412,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(c92035412.spcon)
	e2:SetTarget(c92035412.sptg)
	e2:SetOperation(c92035412.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查被破坏的卡是否是自己场上表侧表示的名字带有「大日」的装备卡
function c92035412.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousSetCard(0x30)
		and bit.band(c:GetPreviousTypeOnField(),TYPE_EQUIP)~=0
end
-- 发动条件：计算被破坏的「大日」装备卡数量并记录，若数量大于0则可以发动
function c92035412.spcon(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(c92035412.cfilter,nil,tp)
	e:SetLabel(ct)
	return ct>0
end
-- 过滤函数：检查卡组中是否存在可以特殊召唤的名字带有「大日」的调整怪兽
function c92035412.spfilter(c,e,tp)
	return c:IsSetCard(0x30) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动准备：检查自身是否不在连锁中、自己场上是否有空怪兽区域，以及卡组中是否存在可特殊召唤的「大日」调整怪兽
function c92035412.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING)
		-- 检查自己场上是否有可用的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己卡组中是否存在至少1只满足条件的「大日」调整怪兽
		and Duel.IsExistingMatchingCard(c92035412.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息：从卡组特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：根据空位和破坏数量，从卡组选择对应数量的「大日」调整怪兽特殊召唤，并对其施加同调素材限制
function c92035412.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if ft>e:GetLabel() then ft=e:GetLabel() end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1到ft张满足条件的「大日」调整怪兽
	local g=Duel.SelectMatchingCard(tp,c92035412.spfilter,tp,LOCATION_DECK,0,1,ft,nil,e,tp)
	local tc=g:GetFirst()
	while tc do
		-- 将选中的怪兽以表侧表示特殊召唤（单步处理）
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 把这个效果特殊召唤的怪兽作为同调素材的场合，不是名字带有「大日」的怪兽的同调召唤不能使用。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		e1:SetValue(c92035412.synlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
	-- 完成所有怪兽的特殊召唤处理
	Duel.SpecialSummonComplete()
end
-- 同调素材限制：若同调召唤的怪兽不是名字带有「大日」的怪兽，则不能将该怪兽作为同调素材
function c92035412.synlimit(e,c)
	if not c then return false end
	return not c:IsSetCard(0x30)
end
