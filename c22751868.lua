--風雲カラクリ城
-- 效果：
-- 自己场上表侧表示存在的名字带有「机巧」的怪兽把对方场上表侧表示存在的怪兽选择作为攻击对象时，可以把那1只对方怪兽的表示形式变更。此外，场上表侧表示存在的这张卡被破坏送去墓地时，可以选择自己墓地存在的1只4星以上的名字带有「机巧」的怪兽特殊召唤。
function c22751868.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己场上表侧表示存在的名字带有「机巧」的怪兽把对方场上表侧表示存在的怪兽选择作为攻击对象时，可以把那1只对方怪兽的表示形式变更。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22751868,0))  --"改变表示形式"
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetCondition(c22751868.poscon)
	e2:SetTarget(c22751868.postg)
	e2:SetOperation(c22751868.posop)
	c:RegisterEffect(e2)
	-- 场上表侧表示存在的这张卡被破坏送去墓地时，可以选择自己墓地存在的1只4星以上的名字带有「机巧」的怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetDescription(aux.Stringid(22751868,1))  --"特殊召唤"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c22751868.spcon)
	e3:SetTarget(c22751868.sptg)
	e3:SetOperation(c22751868.spop)
	c:RegisterEffect(e3)
end
-- 判断攻击怪兽是否为自己的机巧怪兽且攻击对象为表侧表示怪兽
function c22751868.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击的怪兽
	local a=Duel.GetAttacker()
	-- 获取当前攻击对象怪兽
	local d=Duel.GetAttackTarget()
	return a:IsControler(tp) and a:IsSetCard(0x11) and d:IsFaceup()
end
-- 设置攻击对象为可变更表示形式的目标
function c22751868.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前攻击对象怪兽
	local d=Duel.GetAttackTarget()
	if chk==0 then return d:IsCanChangePosition() end
	-- 将目标怪兽设置为效果处理对象
	Duel.SetTargetCard(d)
end
-- 将目标怪兽变为守备表示
function c22751868.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果处理的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将目标怪兽变为守备表示
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
	end
end
-- 判断此卡是否因破坏而送入墓地且之前在场上正面表示
function c22751868.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
end
-- 筛选满足等级4以上且为机巧族的怪兽
function c22751868.filter(c,e,tp)
	return c:IsLevelAbove(4) and c:IsSetCard(0x11) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足特殊召唤条件
function c22751868.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c22751868.filter(chkc,e,tp) end
	-- 判断场上是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地是否存在符合条件的机巧怪兽
		and Duel.IsExistingTarget(c22751868.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择符合条件的墓地怪兽作为特殊召唤对象
	local g=Duel.SelectTarget(tp,c22751868.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作
function c22751868.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果处理的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
