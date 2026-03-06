--覇王門無限
-- 效果：
-- ←13 【灵摆】 13→
-- ①：自己场上有怪兽存在的场合，自己不能灵摆召唤。这个效果不会被无效化。
-- ②：1回合1次，自己场上有「霸王龙 扎克」存在的场合，以对方场上1只表侧表示怪兽为对象才能发动。自己基本分回复那只怪兽的攻击力的数值。
-- 【怪兽效果】
-- ①：1回合1次，以这张卡以外的自己场上1张表侧表示卡为对象才能发动。那张卡和这张卡破坏，把1只龙族超量怪兽或者龙族灵摆怪兽从额外卡组特殊召唤。这个效果特殊召唤的怪兽的攻击力·守备力变成0，效果无效化，不能作为同调·超量召唤的素材。
-- ②：怪兽区域的这张卡被战斗·效果破坏的场合才能发动。这张卡在自己的灵摆区域放置。
function c22211622.initial_effect(c)
	-- 记录该卡拥有「霸王龙 扎克」的卡名代码
	aux.AddCodeList(c,13331639)
	-- 为该卡添加灵摆怪兽属性
	aux.EnablePendulumAttribute(c)
	-- ①：自己场上有怪兽存在的场合，自己不能灵摆召唤。这个效果不会被无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e1:SetTargetRange(1,0)
	e1:SetCondition(c22211622.splimcon)
	e1:SetTarget(c22211622.splimit)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己场上有「霸王龙 扎克」存在的场合，以对方场上1只表侧表示怪兽为对象才能发动。自己基本分回复那只怪兽的攻击力的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22211622,0))
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(c22211622.rccon)
	e2:SetTarget(c22211622.rctg)
	e2:SetOperation(c22211622.rcop)
	c:RegisterEffect(e2)
	-- ①：1回合1次，以这张卡以外的自己场上1张表侧表示卡为对象才能发动。那张卡和这张卡破坏，把1只龙族超量怪兽或者龙族灵摆怪兽从额外卡组特殊召唤。这个效果特殊召唤的怪兽的攻击力·守备力变成0，效果无效化，不能作为同调·超量召唤的素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(22211622,1))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetTarget(c22211622.sptg)
	e3:SetOperation(c22211622.spop)
	c:RegisterEffect(e3)
	-- ②：怪兽区域的这张卡被战斗·效果破坏的场合才能发动。这张卡在自己的灵摆区域放置。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(22211622,2))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCondition(c22211622.pencon)
	e4:SetTarget(c22211622.pentg)
	e4:SetOperation(c22211622.penop)
	c:RegisterEffect(e4)
end
-- 判断自己场上是否存在怪兽
function c22211622.splimcon(e)
	-- 若自己场上存在怪兽则返回true
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)>0
end
-- 判断是否为灵摆召唤
function c22211622.splimit(e,c,sump,sumtype,sumpos,targetp)
	return bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 筛选「霸王龙 扎克」
function c22211622.rccfilter(c)
	return c:IsFaceup() and c:IsCode(13331639)
end
-- 判断自己场上是否存在「霸王龙 扎克」
function c22211622.rccon(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上存在「霸王龙 扎克」则返回true
	return Duel.IsExistingMatchingCard(c22211622.rccfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 筛选攻击力大于0的表侧表示怪兽
function c22211622.rcfilter(c)
	return c:IsFaceup() and c:GetAttack()>0
end
-- 设置效果处理时选择对方场上表侧表示怪兽作为对象
function c22211622.rctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c22211622.rcfilter(chkc) end
	-- 检查是否存在满足条件的对方场上表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c22211622.rcfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择对方场上表侧表示怪兽作为对象
	local g=Duel.SelectTarget(tp,c22211622.rcfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为回复LP
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetFirst():GetAttack())
end
-- 执行回复LP效果
function c22211622.rcop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 使玩家回复对象怪兽攻击力数值的LP
		Duel.Recover(tp,tc:GetAttack(),REASON_EFFECT)
	end
end
-- 筛选可以被破坏并能特殊召唤龙族超量/灵摆怪兽的自己场上表侧表示卡
function c22211622.desfilter(c,e,tp,mc)
	-- 若该卡为表侧表示且自己场上存在满足条件的龙族超量/灵摆怪兽则返回true
	return c:IsFaceup() and Duel.IsExistingMatchingCard(c22211622.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,Group.FromCards(c,mc))
end
-- 筛选龙族超量/灵摆怪兽
function c22211622.spfilter(c,e,tp,dg)
	return c:IsType(TYPE_XYZ+TYPE_PENDULUM) and c:IsRace(RACE_DRAGON)
		-- 检查该龙族超量/灵摆怪兽是否可以特殊召唤且场上是否有足够位置
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,dg,c)>0
end
-- 设置效果处理时选择自己场上表侧表示卡作为对象
function c22211622.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c22211622.desfilter(chkc,e,tp,c) and chkc~=c end
	-- 检查是否存在满足条件的自己场上表侧表示卡
	if chk==0 then return Duel.IsExistingTarget(c22211622.desfilter,tp,LOCATION_ONFIELD,0,1,c,e,tp,c) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择要破坏的自己场上表侧表示卡
	local g=Duel.SelectTarget(tp,c22211622.desfilter,tp,LOCATION_ONFIELD,0,1,1,c,e,tp,c)
	g:AddCard(c)
	-- 设置效果处理信息为破坏2张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
	-- 设置效果处理信息为特殊召唤1只龙族超量/灵摆怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行特殊召唤龙族超量/灵摆怪兽效果
function c22211622.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理时选择的对象卡
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) then return end
	local dg=Group.FromCards(c,tc)
	-- 若成功破坏2张卡则继续处理
	if Duel.Destroy(dg,REASON_EFFECT)==2 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的龙族超量/灵摆怪兽
		local g=Duel.SelectMatchingCard(tp,c22211622.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
		if g:GetCount()==0 then return end
		local sc=g:GetFirst()
		-- 执行特殊召唤步骤
		if Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
			-- 使特殊召唤的怪兽效果无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e1,true)
			-- 使特殊召唤的怪兽不能发动效果
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e2,true)
			-- 使特殊召唤的怪兽攻击力和守备力变为0且不能作为同调/超量素材
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_SET_ATTACK_FINAL)
			e3:SetValue(0)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e3,true)
			local e4=e3:Clone()
			e4:SetCode(EFFECT_SET_DEFENSE_FINAL)
			sc:RegisterEffect(e4,true)
			local e5=e3:Clone()
			e5:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
			e5:SetValue(1)
			sc:RegisterEffect(e5,true)
			local e6=e5:Clone()
			e6:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
			sc:RegisterEffect(e6,true)
		end
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
end
-- 判断该卡是否从怪兽区域被破坏
function c22211622.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 设置灵摆区域放置效果的处理信息
function c22211622.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家灵摆区域是否有空位
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 执行将该卡放置到灵摆区域
function c22211622.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将该卡移动到玩家的灵摆区域
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
