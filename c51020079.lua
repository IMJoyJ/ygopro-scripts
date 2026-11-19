--サイボーグドクター
-- 效果：
-- 把自己场上存在的1只调整解放发动。和解放怪兽相同属性·等级的1只怪兽从自己墓地特殊召唤。这个效果1回合只能使用1次。
function c51020079.initial_effect(c)
	-- 把自己场上存在的1只调整解放发动。和解放怪兽相同属性·等级的1只怪兽从自己墓地特殊召唤。这个效果1回合只能使用1次。
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
-- 过滤函数，筛选自己场上存在的调整怪兽，且墓地中存在与其相同等级和属性并可作为对象特招的怪兽
function c51020079.rfilter(c,e,tp)
	-- 检查怪兽c是否为调整，且自己墓地存在与c相同等级和属性的可特殊召唤对象怪兽
	return c:IsType(TYPE_TUNER) and Duel.IsExistingTarget(c51020079.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c:GetLevel(),c:GetAttribute())
end
-- 过滤函数，筛选等级为lv、属性为att且可以被特殊召唤的怪兽
function c51020079.spfilter(c,e,tp,lv,att)
	return c:IsLevel(lv) and c:IsAttribute(att) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的Target函数，先解放自己场上1只调整并记录其等级和属性，再选择自己墓地1只同属性·等级的怪兽作为对象
function c51020079.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local lv,att=e:GetLabel()
		return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c51020079.spfilter(chkc,e,tp,lv,att)
	end
	-- 发动条件检测时，检查自己场上是否存在至少1只满足rfilter条件的可解放调整怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c51020079.rfilter,1,nil,e,tp) end
	-- 让自己从自己场上选择1只满足rfilter条件的调整怪兽用于解放
	local rg=Duel.SelectReleaseGroup(tp,c51020079.rfilter,1,1,nil,e,tp)
	local r=rg:GetFirst()
	local lv=r:GetLevel()
	local att=r:GetAttribute()
	e:SetLabel(lv,att)
	-- 将选中的调整怪兽作为发动代价解放
	Duel.Release(rg,REASON_COST)
	-- 向自己发送选择提示信息：“请选择要特殊召唤的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让自己在自己墓地选择1只与解放怪兽同等级同属性的怪兽作为连锁对象
	local g=Duel.SelectTarget(tp,c51020079.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,lv,att)
	-- 设置操作信息，声明将特殊召唤对象卡g中的1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果的Operation函数，确认对象卡与效果保持关联后，将其表侧表示特殊召唤
function c51020079.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁指定的第1张对象卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
