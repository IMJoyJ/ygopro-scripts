--サイボーグドクター
-- 效果：
-- 把自己场上存在的1只调整解放发动。和解放怪兽相同属性·等级的1只怪兽从自己墓地特殊召唤。这个效果1回合只能使用1次。
function c51020079.initial_effect(c)
	-- 对应效果原文：“把自己场上存在的1只调整解放发动。和解放怪兽相同属性·等级的1只怪兽从自己墓地特殊召唤。这个效果1回合只能使用1次。”
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51020079,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c51020079.sptg)
	e1:SetOperation(c51020079.spop)
	c:RegisterEffect(e1)
end
-- 定义解放怪兽的筛选条件：该卡为调整怪兽，且墓地存在与之同属性同等级并能被效果特殊召唤的怪兽。
function c51020079.rfilter(c,e,tp)
	-- 返回true当且仅当c是调整怪兽，且墓地存在至少1张满足spfilter（等级、属性匹配且可特殊召唤）的卡。
	return c:IsType(TYPE_TUNER) and Duel.IsExistingTarget(c51020079.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c:GetLevel(),c:GetAttribute())
end
-- 定义墓地特殊召唤对象的筛选条件：等级与解放怪兽相同、属性与解放怪兽相同、且可以被当前效果特殊召唤。
function c51020079.spfilter(c,e,tp,lv,att)
	return c:IsLevel(lv) and c:IsAttribute(att) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标处理函数：检查是否有可解放的调整及墓地目标；选择并解放1只调整；再选择墓地1只符合条件怪兽作为对象，并设置特殊召唤操作信息。
function c51020079.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c51020079.spfilter(chkc,e,tp) end
	-- 在效果发动合法性检查时，确认场上是否存在至少1只满足rfilter条件的可解放调整（且墓地有对应目标）。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c51020079.rfilter,1,nil,e,tp) end
	-- 从自己场上选择1只满足rfilter条件的调整怪兽作为发动代价。
	local rg=Duel.SelectReleaseGroup(tp,c51020079.rfilter,1,1,nil,e,tp)
	local r=rg:GetFirst()
	local lv=r:GetLevel()
	local att=r:GetAttribute()
	-- 将选择的调整怪兽解放，作为效果的发动代价。
	Duel.Release(rg,REASON_COST)
	-- 向玩家显示选择特殊召唤对象的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只与解放怪兽相同属性·等级且可特殊召唤的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c51020079.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,lv,att)
	-- 设置连锁操作信息，声明本效果将进行1只怪兽的特殊召唤，用于后续效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理时的操作函数：取得对象怪兽，若仍与效果关联，则将其特殊召唤到自己场上。
function c51020079.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象怪兽（墓地中目标怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上，不检查召唤条件和苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
