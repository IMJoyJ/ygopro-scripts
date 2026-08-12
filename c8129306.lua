--六花精プリム
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的怪兽被解放的场合才能发动。这张卡从手卡守备表示特殊召唤。
-- ②：以自己场上最多2只植物族怪兽为对象才能发动。那些怪兽的等级直到回合结束时上升2星。
function c8129306.initial_effect(c)
	-- ①：自己场上的怪兽被解放的场合才能发动。这张卡从手卡守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(8129306,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_CUSTOM+8129306)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,8129306)
	e1:SetCondition(c8129306.spcon)
	e1:SetTarget(c8129306.sptg)
	e1:SetOperation(c8129306.spop)
	c:RegisterEffect(e1)
	-- ②：以自己场上最多2只植物族怪兽为对象才能发动。那些怪兽的等级直到回合结束时上升2星。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(8129306,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,8129307)
	e2:SetTarget(c8129306.lvtg)
	e2:SetOperation(c8129306.lvop)
	c:RegisterEffect(e2)
	if not c8129306.global_check then
		c8129306.global_check=true
		-- ①：自己场上的怪兽被解放的场合才能发动。
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_RELEASE)
		ge2:SetCondition(c8129306.regcon)
		ge2:SetOperation(c8129306.regop)
		-- 注册全局环境效果，用于监听怪兽被解放的事件。
		Duel.RegisterEffect(ge2,0)
	end
end
-- 过滤在怪兽区域被解放的、且原本控制者为指定玩家的怪兽。
function c8129306.spfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 检查是否有玩家场上的怪兽被解放，并记录是哪位玩家的怪兽被解放。
function c8129306.regcon(e,tp,eg,ep,ev,re,r,rp)
	local v=0
	if eg:IsExists(c8129306.spfilter,1,nil,0) then v=v+1 end
	if eg:IsExists(c8129306.spfilter,1,nil,1) then v=v+2 end
	if v==0 then return false end
	e:SetLabel(({0,1,PLAYER_ALL})[v])
	return true
end
-- 触发自定义事件，传递被解放怪兽的控制者信息。
function c8129306.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 触发自定义事件，将解放怪兽的玩家信息作为参数传递。
	Duel.RaiseEvent(eg,EVENT_CUSTOM+8129306,re,r,rp,ep,e:GetLabel())
end
-- 检查被解放的怪兽是否包含自己场上的怪兽。
function c8129306.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ev==tp or ev==PLAYER_ALL
end
-- 效果①（特殊召唤）的发动准备与合法性检测。
function c8129306.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空怪兽位，以及手卡中的这张卡是否能以守备表示特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置当前连锁的操作信息为特殊召唤手卡的这张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①（特殊召唤）的效果处理。
function c8129306.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡从手卡往自己场上表侧守备表示特殊召唤。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 过滤场上表侧表示、等级在1星以上且是植物族的怪兽。
function c8129306.lvfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT) and c:IsLevelAbove(1)
end
-- 效果②（等级上升）的发动准备与对象选择。
function c8129306.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c8129306.lvfilter(chkc) end
	-- 检查自己场上是否存在至少1只符合条件的植物族怪兽。
	if chk==0 then return Duel.IsExistingTarget(c8129306.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1到2只符合条件的植物族怪兽作为效果的对象。
	Duel.SelectTarget(tp,c8129306.lvfilter,tp,LOCATION_MZONE,0,1,2,nil)
end
-- 过滤出仍存在于场上表侧表示且仍是该效果对象的怪兽。
function c8129306.cfilter(c,e)
	return c:IsFaceup() and c:IsRelateToEffect(e)
end
-- 效果②（等级上升）的效果处理。
function c8129306.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍合法的对象怪兽。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c8129306.cfilter,nil,e)
	local tc=g:GetFirst()
	while tc do
		-- 那些怪兽的等级直到回合结束时上升2星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
