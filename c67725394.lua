--らくがきじゅう－てらの
-- 效果：
-- 这张卡可以把1只恐龙族怪兽解放作上级召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：场上有恐龙族怪兽存在的场合，自己·对方的主要阶段才能发动。手卡的这张卡上级召唤。
-- ②：这张卡召唤成功的场合才能发动。选场上1只怪兽破坏。这张卡把「涂鸦兽」怪兽解放作上级召唤的场合，再让这张卡的攻击力上升破坏的怪兽的攻击力一半数值。
function c67725394.initial_effect(c)
	-- 这张卡可以把1只恐龙族怪兽解放作上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67725394,0))  --"把1只恐龙族怪兽解放作上级召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c67725394.otcon)
	e1:SetOperation(c67725394.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e2)
	-- ①：场上有恐龙族怪兽存在的场合，自己·对方的主要阶段才能发动。手卡的这张卡上级召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(67725394,1))
	e3:SetCategory(CATEGORY_SUMMON+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1,67725394)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetCondition(c67725394.sumcon)
	e3:SetTarget(c67725394.sumtg)
	e3:SetOperation(c67725394.sumop)
	c:RegisterEffect(e3)
	-- ②：这张卡召唤成功的场合才能发动。选场上1只怪兽破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(67725394,2))
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetTarget(c67725394.destg)
	e4:SetOperation(c67725394.desop)
	c:RegisterEffect(e4)
	-- 这张卡把「涂鸦兽」怪兽解放作上级召唤的场合
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_MATERIAL_CHECK)
	e5:SetValue(c67725394.valcheck)
	e5:SetLabelObject(e4)
	c:RegisterEffect(e5)
end
-- 过滤条件：属于恐龙族且由自己控制（可里侧）或在对方场上表侧表示的怪兽
function c67725394.rfilter(c,tp)
	return c:IsRace(RACE_DINOSAUR) and (c:IsControler(tp) or c:IsFaceup())
end
-- 上级召唤规则的特殊召唤条件判定函数
function c67725394.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上满足解放条件的恐龙族怪兽组
	local mg=Duel.GetMatchingGroup(c67725394.rfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 判定自身等级是否在7星以上、所需祭品数是否在1个以下，且场上是否存在可解放的怪兽
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 上级召唤规则的特殊召唤操作处理函数
function c67725394.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取场上满足解放条件的恐龙族怪兽组
	local mg=Duel.GetMatchingGroup(c67725394.rfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 让玩家选择1只怪兽作为祭品
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 解放选中的怪兽进行上级召唤
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 过滤条件：场上表侧表示的恐龙族怪兽
function c67725394.cfilter(c)
	return c:IsRace(RACE_DINOSAUR) and c:IsFaceup()
end
-- 效果①的发动条件判定函数
function c67725394.sumcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在表侧表示的恐龙族怪兽
	return Duel.IsExistingMatchingCard(c67725394.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 检查当前是否为双方的主要阶段
		and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 效果①的发动准备与可行性检查函数
function c67725394.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSummonable(true,nil,1) or c:IsMSetable(true,nil,1) end
	-- 设置操作信息：包含召唤分类，数量为1
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,c,1,0,0)
end
-- 效果①的效果处理函数
function c67725394.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local pos=0
	if c:IsSummonable(true,nil,1) then pos=pos+POS_FACEUP_ATTACK end
	if c:IsMSetable(true,nil,1) then pos=pos+POS_FACEDOWN_DEFENSE end
	if pos==0 then return end
	-- 若同时满足召唤与盖放条件，则让玩家选择表示形式
	if Duel.SelectPosition(tp,c,pos)==POS_FACEUP_ATTACK then
		-- 将这张卡表侧攻击表示上级召唤
		Duel.Summon(tp,c,true,nil,1)
	else
		-- 将这张卡里侧守备表示上级盖放
		Duel.MSet(tp,c,true,nil,1)
	end
end
-- 效果②的发动准备与可行性检查函数
function c67725394.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1只怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取场上所有的怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息：包含破坏分类，数量为1
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②的效果处理函数
function c67725394.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择场上1只怪兽
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		-- 为选中的怪兽显示被选为对象的动画效果
		Duel.HintSelection(g)
		-- 破坏选中的怪兽，并检查是否是用「涂鸦兽」怪兽解放召唤且自身在场上表侧表示
		if Duel.Destroy(g,REASON_EFFECT)~=0 and e:GetLabel()==1 and c:IsRelateToEffect(e) and c:IsFaceup() then
			-- 再让这张卡的攻击力上升破坏的怪兽的攻击力一半数值。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			e1:SetValue(math.ceil(g:GetFirst():GetBaseAttack()/2))
			c:RegisterEffect(e1)
		end
	end
end
-- 检查召唤素材是否包含「涂鸦兽」怪兽的函数
function c67725394.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsSetCard,1,nil,0x1185) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
