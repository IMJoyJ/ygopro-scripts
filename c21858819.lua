--No.XX インフィニティ・ダークホープ
-- 效果：
-- 10星怪兽×2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己或者对方的怪兽被战斗破坏送去墓地时，把这张卡1个超量素材取除，以那1只怪兽为对象才能发动。那只怪兽在自己场上守备表示特殊召唤。
-- ②：以这张卡以外的自己场上1只特殊召唤的表侧表示怪兽为对象才能发动。自己基本分回复那只怪兽的原本攻击力的数值。
function c21858819.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：以等级10的怪兽2只以上（最多99只）为素材进行XYZ召唤。
	aux.AddXyzProcedure(c,nil,10,2,nil,nil,99)
	c:EnableReviveLimit()
	-- ①：自己或者对方的怪兽被战斗破坏送去墓地时，把这张卡1个超量素材取除，以那1只怪兽为对象才能发动。那只怪兽在自己场上守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21858819,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,21858819)
	e1:SetCost(c21858819.cost)
	e1:SetTarget(c21858819.target)
	e1:SetOperation(c21858819.activate)
	c:RegisterEffect(e1)
	-- ②：以这张卡以外的自己场上1只特殊召唤的表侧表示怪兽为对象才能发动。自己基本分回复那只怪兽的原本攻击力的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21858819,1))
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,21858820)
	e2:SetTarget(c21858819.rectg)
	e2:SetOperation(c21858819.recop)
	c:RegisterEffect(e2)
end
-- 代价函数：发动前检查这张卡是否有1个超量素材可去除；支付时将这张卡的1个超量素材去除作为发动代价。
function c21858819.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 筛选被战斗破坏送去墓地、且能够成为此效果对象、并能以表侧守备表示被特殊召唤的怪兽。
function c21858819.filter(c,e,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE)
		and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 发动时条件判定和取对象准备：从战斗破坏送墓的怪兽中筛出满足条件的卡，将其中一张暂存为LabelObject，并确认存在可特殊召唤的对象。
function c21858819.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=eg:Filter(c21858819.filter,nil,e,tp)
		e:SetLabelObject(g:GetFirst())
		return g:GetCount()~=0
	end
	-- 把选定的那只怪兽设为当前连锁的对象。
	Duel.SetTargetCard(e:GetLabelObject())
	-- 设置操作信息：本次效果将特殊召唤对象怪兽1只。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetLabelObject(),1,0,0)
end
-- 效果处理：若对象仍与此效果关联，则将那只怪兽以表侧守备表示特殊召唤到自己场上。
function c21858819.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次效果的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧守备表示特殊召唤到自己场上（不进行苏生限制/召唤条件检测）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 选择怪兽的过滤条件：表侧表示、原本攻击力大于0、且是通过特殊召唤方式出场的怪兽。
function c21858819.recfilter(c)
	return c:IsFaceup() and c:GetBaseAttack()>0 and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- ②效果的取对象处理：不能选择自身；选择自己场上1只满足条件的表侧表示特殊召唤怪兽，并设置回复LP的操作信息。
function c21858819.rectg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc~=c and chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c21858819.recfilter(chkc) end
	-- 发动条件判定：确认自己场上是否存在1只满足条件且可成为对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c21858819.recfilter,tp,LOCATION_MZONE,0,1,c) end
	-- 向玩家发出选择对象的目标提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己场上选择1只满足条件的怪兽（不能选择这张卡自身）作为效果对象。
	local g=Duel.SelectTarget(tp,c21858819.recfilter,tp,LOCATION_MZONE,0,1,1,c)
	-- 设置操作信息：效果将回复基本分，回复数值为目标怪兽的原本攻击力。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetFirst():GetBaseAttack())
end
-- 效果处理：取得对象怪兽，若对象仍与此效果相关且满足表侧表示、原本攻击力大于0，则回复相应基本分。
function c21858819.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次回复效果选择的怪兽对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:GetBaseAttack()>0 then
		-- 回复自己基本分，数值为目标怪兽的原本攻击力。
		Duel.Recover(tp,tc:GetBaseAttack(),REASON_EFFECT)
	end
end
