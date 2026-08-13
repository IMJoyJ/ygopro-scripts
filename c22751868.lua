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
	-- 此外，场上表侧表示存在的这张卡被破坏送去墓地时，可以选择自己墓地存在的1只4星以上的名字带有「机巧」的怪兽特殊召唤。
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
-- 判断变更表示形式效果的发动条件：攻击方是自己场上表侧表示且名字带有「机巧」的怪兽，攻击对象是对方场上表侧表示存在的怪兽。
function c22751868.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击宣言的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取被选择为攻击对象的对方怪兽。
	local d=Duel.GetAttackTarget()
	return a:IsControler(tp) and a:IsSetCard(0x11) and d:IsFaceup()
end
-- 目标选择处理：获取本次战斗的攻击对象；若该对象可以变更表示形式，则将其直接设置为这张卡效果的对象（无需玩家额外选择）。
function c22751868.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取本次战斗被选择为攻击对象的对方怪兽。
	local d=Duel.GetAttackTarget()
	if chk==0 then return d:IsCanChangePosition() end
	-- 将攻击对象登记为这张卡效果的对象，效果处理时以此对象为准。
	Duel.SetTargetCard(d)
end
-- 效果处理：取出对象；若对象仍为表侧表示且与效果关联，则将其表示形式变更，表侧攻击表示与表侧守备表示互换（里侧表示不处理）。
function c22751868.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出通过Duel.SetTargetCard登记的攻击对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 变更该对象怪兽的表示形式：表侧攻击表示变为表侧守备表示，表侧守备表示变为表侧攻击表示。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
	end
end
-- 特殊召唤效果的发动条件：这张卡在场上表侧表示存在时被破坏并送去墓地。
function c22751868.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
end
-- 特殊召唤对象的过滤条件：等级4以上、名字带有「机巧」、且满足当前特殊召唤条件，可以作为效果特殊召唤的对象。
function c22751868.filter(c,e,tp)
	return c:IsLevelAbove(4) and c:IsSetCard(0x11) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的目标选择：若指定了对象则验证其位于自己墓地且符合「机巧」特殊召唤条件；若为发动合法性检查则确认有可用区域并存在合法对象。
function c22751868.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c22751868.filter(chkc,e,tp) end
	-- 发动合法性检查：确认自己场上存在可用的主要怪兽区域，用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动合法性检查：确认自己墓地中存在至少1只满足4星以上、名字带有「机巧」且可被特殊召唤的怪兽。
		and Duel.IsExistingTarget(c22751868.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示“请选择要特殊召唤的卡”的提示文字，用于选择卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地中选择1只符合条件的「机巧」怪兽，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,c22751868.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将本次连锁的操作信息登记为特殊召唤该选择的怪兽，供其他卡片效果联动检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果处理：取出对象；若对象仍与该效果关联，则将其以表侧攻击表示特殊召唤到自己场上。
function c22751868.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出之前选择并登记的特殊召唤对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
