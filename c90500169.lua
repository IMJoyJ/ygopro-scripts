--レベルダウン！？
-- 效果：
-- 选择场上表侧表示存在的1只持有「LV」的怪兽发动。选择的卡回到原本的持有者卡组，从持有者墓地把1只比那张卡的「LV」低的同名怪兽无视召唤条件在持有者场上特殊召唤。
function c90500169.initial_effect(c)
	-- 选择场上表侧表示存在的1只持有「LV」的怪兽发动。选择的卡回到原本的持有者卡组，从持有者墓地把1只比那张卡的「LV」低的同名怪兽无视召唤条件在持有者场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c90500169.target)
	e1:SetOperation(c90500169.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选场上表侧表示、属于「LV」系列、能回到卡组，且其持有者墓地存在可特殊召唤的低等级同名怪兽的怪兽
function c90500169.filter(c,e,tp)
	if c:IsFacedown() or not c:IsSetCard(0x41) or not c:IsAbleToDeck() then return false end
	local op=c:GetOwner()
	-- 获取目标怪兽持有者场上的可用怪兽区域数量，用于后续特殊召唤的空间判定
	local locct=Duel.GetLocationCount(op,LOCATION_MZONE)
	local cp=c:GetControler()
	if op==cp and locct<=-1 then return false end
	if op~=cp and locct<=0 then return false end
	local code=c:GetCode()
	local class=_G["c"..code]
	-- 检查该怪兽是否具有更低等级的同名关系定义，且其持有者的墓地中是否存在至少1只可特殊召唤的对应怪兽
	return class and class.lvdn~=nil and Duel.IsExistingMatchingCard(c90500169.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,class,e,tp,op)
end
-- 过滤函数：筛选属于目标怪兽持有者墓地的、在lvdn表（更低等级同名怪兽）中且可以特殊召唤的怪兽
function c90500169.spfilter(c,class,e,tp,op)
	if not c:IsControler(op) then return false end
	local code=c:GetCode()
	return c:IsCode(table.unpack(class.lvdn)) and c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP,op)
end
-- 效果发动的准备函数：进行对象选择并设置相关的操作信息
function c90500169.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c90500169.filter(chkc,e,tp) end
	-- 在发动阶段，检查场上是否存在至少1只满足条件的可选择怪兽
	if chk==0 then return Duel.IsExistingTarget(c90500169.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp) end
	-- 向发动效果的玩家发送提示信息，要求选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择1只满足条件的怪兽作为当前效果的对象
	local g=Duel.SelectTarget(tp,c90500169.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp)
	-- 设置操作信息：将选中的对象怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 设置操作信息：从墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理函数：执行将对象怪兽送回卡组以及从墓地特殊召唤低等级同名怪兽的操作
function c90500169.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	local code=tc:GetCode()
	local op=tc:GetOwner()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	-- 将对象怪兽送回持有者的卡组并洗牌，若未能成功送回则后续处理不适用
	if Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 then return end
	-- 检查目标怪兽持有者的场上是否还有可用的怪兽区域，若无则无法进行特殊召唤
	if Duel.GetLocationCount(op,LOCATION_MZONE)<=0 then return end
	local class=_G["c"..code]
	if class==nil or class.lvdn==nil then return end
	-- 向玩家发送提示信息，要求选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从持有者的墓地中选择1只符合条件的低等级同名怪兽
	local g=Duel.SelectMatchingCard(tp,c90500169.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,class,e,tp,op)
	if g:GetCount()>0 then
		-- 将选择的怪兽在持有者场上以表侧表示无视召唤条件特殊召唤
		Duel.SpecialSummon(g,0,tp,op,true,false,POS_FACEUP)
	end
end
