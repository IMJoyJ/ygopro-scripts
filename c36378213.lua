--キューキューロイド
-- 效果：
-- 名字带有「机人」的怪兽从自己墓地加入手卡时，可以特殊召唤那只怪兽。
function c36378213.initial_effect(c)
	-- 效果原文：名字带有「机人」的怪兽从自己墓地加入手卡时，可以特殊召唤那只怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36378213,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c36378213.target)
	e1:SetOperation(c36378213.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的卡片组：从墓地加入手卡且控制者为自己且名字带有「机人」且可以特殊召唤
function c36378213.filter(c,e,tp)
	return c:IsPreviousLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp) and c:IsSetCard(0x16)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：设置连锁处理的目标卡片为满足条件的卡片组，并设置操作信息为特殊召唤
function c36378213.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(c36378213.filter,nil,e,tp)
	-- 效果作用：判断是否满足发动条件，即存在满足条件的卡片且场上存在空位
	if chk==0 then return g:GetCount()~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 效果作用：将当前连锁处理的对象设置为eg（即触发效果的卡片）
	Duel.SetTargetCard(eg)
	-- 效果作用：设置操作信息为特殊召唤，目标为g（满足条件的卡片组）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 检索满足条件的卡片组：从墓地加入手卡且控制者为自己且名字带有「机人」且可以特殊召唤且与当前效果有关联
function c36378213.spfilter(c,e,tp)
	return c:IsPreviousLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp) and c:IsSetCard(0x16)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsRelateToEffect(e)
end
-- 效果作用：处理特殊召唤逻辑，包括判断场上空位、过滤卡片、处理青眼精灵龙限制、选择召唤卡片并执行特殊召唤
function c36378213.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取玩家tp场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	local g=eg:Filter(c36378213.spfilter,nil,e,tp)
	if g:GetCount()==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if g:GetCount()>ft then
		-- 效果作用：向玩家tp发送提示信息“请选择要特殊召唤的卡”
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=g:Select(tp,ft,ft,nil)
	end
	-- 效果作用：将满足条件的卡片组以正面表示形式特殊召唤到玩家tp场上
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
