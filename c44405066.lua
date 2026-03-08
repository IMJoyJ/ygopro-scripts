--真紅眼の鋼炎竜
-- 效果：
-- 7星怪兽×2
-- ①：持有超量素材的这张卡不会被效果破坏。
-- ②：只要持有超量素材的这张卡在怪兽区域存在，每次对方把魔法·陷阱·怪兽的效果发动给与对方500伤害。
-- ③：1回合1次，把这张卡1个超量素材取除，以自己墓地1只「真红眼」通常怪兽为对象才能发动。那只怪兽特殊召唤。这个效果在对方回合也能发动。
function c44405066.initial_effect(c)
	-- 添加XYZ召唤手续，使用等级为7的怪兽进行叠放，需要2只怪兽
	aux.AddXyzProcedure(c,nil,7,2)
	c:EnableReviveLimit()
	-- ①：持有超量素材的这张卡不会被效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c44405066.indcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：只要持有超量素材的这张卡在怪兽区域存在，每次对方把魔法·陷阱·怪兽的效果发动给与对方500伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(c44405066.regop)
	c:RegisterEffect(e2)
	-- ③：1回合1次，把这张卡1个超量素材取除，以自己墓地1只「真红眼」通常怪兽为对象才能发动。那只怪兽特殊召唤。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c44405066.damcon)
	e3:SetOperation(c44405066.damop)
	c:RegisterEffect(e3)
	-- 特殊召唤
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(44405066,0))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1)
	e4:SetCost(c44405066.spcost)
	e4:SetTarget(c44405066.sptg)
	e4:SetOperation(c44405066.spop)
	c:RegisterEffect(e4)
end
-- 判断是否持有超量素材
function c44405066.indcon(e)
	return e:GetHandler():GetOverlayCount()>0
end
-- 记录连锁发动标记
function c44405066.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(44405066,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_CHAIN,0,1)
end
-- 判断是否满足伤害触发条件
function c44405066.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetOverlayCount()>0 and ep~=tp and c:GetFlagEffect(44405066)~=0
end
-- 造成对方500伤害
function c44405066.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示发动动画提示
	Duel.Hint(HINT_CARD,0,44405066)
	-- 造成伤害
	Duel.Damage(1-tp,500,REASON_EFFECT)
end
-- 支付1个超量素材作为代价
function c44405066.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 筛选墓地中的「真红眼」通常怪兽
function c44405066.spfilter(c,e,tp)
	return c:IsSetCard(0x3b) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置选择目标
function c44405066.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c44405066.spfilter(chkc,e,tp) end
	-- 判断是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否存在符合条件的墓地怪兽
		and Duel.IsExistingTarget(c44405066.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c44405066.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理特殊召唤效果
function c44405066.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
