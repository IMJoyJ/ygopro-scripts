--サイバネット・カスケード
-- 效果：
-- ①：自己对连接怪兽的连接召唤成功的场合，以那1只作为连接素材的自己墓地的怪兽为对象才能发动。那只怪兽特殊召唤。
function c4433488.initial_effect(c)
	-- ①：自己对连接怪兽的连接召唤成功的场合，以那1只作为连接素材的自己墓地的怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c4433488.target)
	e1:SetOperation(c4433488.activate)
	c:RegisterEffect(e1)
end
-- 过滤出由玩家tp连接召唤成功的连接怪兽
function c4433488.cfilter(c,tp)
	return c:IsType(TYPE_LINK) and c:IsSummonType(SUMMON_TYPE_LINK) and c:IsSummonPlayer(tp)
end
-- 检查墓地怪兽是否可以被特殊召唤且为连接素材之一
function c4433488.spfilter(c,e,tp,g)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and g and g:IsContains(c)
end
-- 处理效果的发动条件与目标选择
function c4433488.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local lc=eg:Filter(c4433488.cfilter,nil,tp):GetFirst()
	if chkc then return chkc:IsControler(tp) and c4433488.spfilter(chkc,e,tp,lc:GetMaterial()) end
	-- 判断是否满足发动条件：存在连接怪兽且场上存在空位
	if chk==0 then return lc and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足发动条件：墓地存在符合条件的怪兽
		and Duel.IsExistingTarget(c4433488.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,lc:GetMaterial()) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择符合条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c4433488.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,lc:GetMaterial())
	-- 设置效果处理信息，确定将要特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理效果的发动效果
function c4433488.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
