--貪食魚グリーディス
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：以持有对方手卡数量以下的等级的自己墓地1只鱼族·海龙族·水族怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能把效果发动。
-- ②：这张卡作为同调素材送去墓地的场合才能发动。这张卡为同调素材的同调怪兽的攻击力·守备力上升对方手卡数量×200。
function c8576764.initial_effect(c)
	-- ①：以持有对方手卡数量以下的等级的自己墓地1只鱼族·海龙族·水族怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能把效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(8576764,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,8576764)
	e1:SetTarget(c8576764.sptg)
	e1:SetOperation(c8576764.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡作为同调素材送去墓地的场合才能发动。这张卡为同调素材的同调怪兽的攻击力·守备力上升对方手卡数量×200。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(8576764,1))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c8576764.atkcon)
	e2:SetTarget(c8576764.atktg)
	e2:SetOperation(c8576764.atkop)
	c:RegisterEffect(e2)
	-- 建立作为素材的卡与因成为素材而触发的效果之间的关联，确保后续能正确获取同调召唤出的怪兽
	aux.CreateMaterialReasonCardRelation(c,e2)
end
-- 过滤自己墓地中等级在指定数值以下、且可以特殊召唤的鱼族·海龙族·水族怪兽
function c8576764.spfilter(c,e,tp,lv)
	return c:IsRace(RACE_FISH+RACE_SEASERPENT+RACE_AQUA) and c:IsLevelBelow(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与对象选择
function c8576764.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取对方手卡数量作为等级上限
	local lv=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c8576764.spfilter(chkc,e,tp,lv) end
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在符合条件的、可作为效果对象的怪兽
		and Duel.IsExistingTarget(c8576764.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,lv) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c8576764.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,lv)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的效果处理，将对象怪兽特殊召唤并使其在本回合不能发动效果
function c8576764.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍与效果关联，则将其以表侧表示特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽在这个回合不能把效果发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	-- 完成特殊召唤的后续处理
	Duel.SpecialSummonComplete()
end
-- 效果②的发动条件：这张卡作为同调素材送去墓地
function c8576764.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 效果②的发动准备与目标设定
function c8576764.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=e:GetHandler():GetReasonCard()
	-- 检查同调怪兽是否仍与效果关联且表侧表示存在，以及对方手卡是否大于0
	if chk==0 then return rc:IsRelateToEffect(e) and rc:IsFaceup() and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	-- 将该同调怪兽设定为本效果的目标卡片
	Duel.SetTargetCard(rc)
end
-- 效果②的效果处理，使作为同调素材的同调怪兽的攻击力·守备力上升对方手卡数量×200
function c8576764.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果目标的同调怪兽
	local rc=Duel.GetFirstTarget()
	-- 获取对方当前的手卡数量
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	if rc:IsRelateToChain() and rc:IsFaceup() and ct>0 then
		-- 攻击力……上升对方手卡数量×200
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(ct*200)
		rc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		rc:RegisterEffect(e2)
	end
end
