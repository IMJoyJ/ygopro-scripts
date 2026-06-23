--除草獣
-- 效果：
-- 1回合1次，可以把自己场上存在的1只植物族怪兽解放，选择对方场上表侧表示存在的1张卡破坏。此外，这张卡在墓地存在，场上存在的植物族怪兽被破坏时，这张卡可以从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合从游戏中除外。
function c35448319.initial_effect(c)
	-- 1回合1次，可以把自己场上存在的1只植物族怪兽解放，选择对方场上表侧表示存在的1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35448319,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c35448319.cost)
	e1:SetTarget(c35448319.target)
	e1:SetOperation(c35448319.operation)
	c:RegisterEffect(e1)
	-- 此外，这张卡在墓地存在，场上存在的植物族怪兽被破坏时，这张卡可以从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合从游戏中除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35448319,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c35448319.spcon)
	e2:SetTarget(c35448319.sptg)
	e2:SetOperation(c35448319.spop)
	c:RegisterEffect(e2)
end
-- 检查玩家场上是否存在至少1张满足条件的植物族怪兽（可解放）
function c35448319.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否存在至少1张满足条件的植物族怪兽（可解放）
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsRace,1,nil,RACE_PLANT) end
	-- 让玩家从场上选择1张满足条件的植物族怪兽（可解放）
	local sg=Duel.SelectReleaseGroup(tp,Card.IsRace,1,1,nil,RACE_PLANT)
	-- 以代價原因解放选择的怪兽
	Duel.Release(sg,REASON_COST)
end
-- 过滤函数，判断目标怪兽是否表侧表示
function c35448319.filter(c)
	return c:IsFaceup()
end
-- 设置效果目标，选择对方场上表侧表示存在的1张卡
function c35448319.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c35448319.filter(chkc) end
	-- 检查玩家场上是否存在至少1张满足条件的对方场上表侧表示的卡
	if chk==0 then return Duel.IsExistingTarget(c35448319.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家提示“请选择要破坏的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上表侧表示存在的1张卡作为目标
	local g=Duel.SelectTarget(tp,c35448319.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果操作信息，确定要破坏的卡的数量为1
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行效果处理，破坏目标卡
function c35448319.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 以效果原因破坏目标卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤函数，判断被破坏的怪兽是否为植物族且在场上表侧表示过
function c35448319.spfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and bit.band(c:GetPreviousRaceOnField(),RACE_PLANT)~=0
end
-- 判断是否满足特殊召唤条件，即被破坏的卡中存在植物族怪兽
function c35448319.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c35448319.spfilter,1,nil)
end
-- 判断是否满足特殊召唤条件，即玩家场上存在空位且此卡可特殊召唤
function c35448319.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家场上是否存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果操作信息，确定要特殊召唤的卡为自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤处理，将此卡特殊召唤到场上，并设置其离场时从游戏中除外
function c35448319.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否能特殊召唤成功并执行特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合从游戏中除外
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
