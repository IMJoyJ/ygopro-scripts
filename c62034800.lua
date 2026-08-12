--無限起動ロックアンカー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从手卡把「无限起动 攀岩锚挖掘机」以外的1只机械族·地属性怪兽守备表示特殊召唤。
-- ②：以这张卡以外的自己场上1只机械族怪兽为对象才能发动。那只怪兽和这张卡直到回合结束时变成那2只的原本等级合计的等级。
function c62034800.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从手卡把「无限起动 攀岩锚挖掘机」以外的1只机械族·地属性怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62034800,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,62034800)
	e1:SetTarget(c62034800.sptg)
	e1:SetOperation(c62034800.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：以这张卡以外的自己场上1只机械族怪兽为对象才能发动。那只怪兽和这张卡直到回合结束时变成那2只的原本等级合计的等级。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(62034800,1))
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,62034801)
	e3:SetTarget(c62034800.lvtg)
	e3:SetOperation(c62034800.lvop)
	c:RegisterEffect(e3)
end
-- 过滤手牌中除「无限起动 攀岩锚挖掘机」以外的机械族·地属性且可以守备表示特殊召唤的怪兽
function c62034800.spfilter(c,e,tp)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH) and not c:IsCode(62034800)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 特殊召唤效果的发动条件判定与操作信息设置
function c62034800.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在满足特殊召唤过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c62034800.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息为从手牌特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 特殊召唤效果的处理，从手牌选择1只符合条件的怪兽守备表示特殊召唤
function c62034800.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否已满，若满则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌中选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c62034800.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧守备表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 过滤场上表侧表示、有等级的机械族怪兽
function c62034800.lvfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsLevelAbove(0)
end
-- 等级改变效果的发动条件判定与选择对象处理
function c62034800.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc~=c and chkc:IsLocation(LOCATION_MZONE) and c62034800.lvfilter(chkc) end
	-- 检查场上是否存在除自身以外可以作为效果对象的机械族怪兽
	if chk==0 then return Duel.IsExistingTarget(c62034800.lvfilter,tp,LOCATION_MZONE,0,1,c) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只除自身以外的机械族怪兽作为效果对象
	Duel.SelectTarget(tp,c62034800.lvfilter,tp,LOCATION_MZONE,0,1,1,c)
end
-- 等级改变效果的处理，将自身与目标怪兽的等级变更为两者原本等级的合计值
function c62034800.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		local lv=c:GetOriginalLevel()+tc:GetOriginalLevel()
		c62034800.setlv(c,c,lv)
		c62034800.setlv(c,tc,lv)
	end
end
-- 辅助函数：为指定怪兽注册一个直到回合结束时等级改变的效果
function c62034800.setlv(c,ec,lv)
	-- 直到回合结束时变成那2只的原本等级合计的等级。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(lv)
	ec:RegisterEffect(e1)
end
