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
-- 效果发动代价：确认可以解放植物族怪兽后，选择自己场上1只植物族怪兽解放作为发动代价。
function c35448319.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：确认自己场上是否存在至少1只植物族怪兽可以解放，以满足发动前提。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsRace,1,nil,RACE_PLANT) end
	-- 从自己场上选择1只植物族怪兽作为解放代价。
	local sg=Duel.SelectReleaseGroup(tp,Card.IsRace,1,1,nil,RACE_PLANT)
	-- 将选中的植物族怪兽解放，作为效果的发动代价。
	Duel.Release(sg,REASON_COST)
end
-- 定义对象筛选条件：卡必须为表侧表示。
function c35448319.filter(c)
	return c:IsFaceup()
end
-- 破坏效果的取对象处理：检测对方场上是否有表侧表示的卡可成为对象；有则让玩家选择1张，并登记为效果对象。
function c35448319.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c35448319.filter(chkc) end
	-- 效果发动条件检测：确认对方场上是否存在至少1张表侧表示的卡可以作为破坏对象。
	if chk==0 then return Duel.IsExistingTarget(c35448319.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向操作玩家显示‘请选择要破坏的卡’的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从对方场上选择1张表侧表示的卡作为效果对象（取对象），并自动登记为当前连锁对象。
	local g=Duel.SelectTarget(tp,c35448319.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 将本次效果处理的信息设定为‘破坏’分类，对象为已选择的1张卡，供后续时点/效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：获取取对象选择的卡片，若该卡仍表侧表示且与效果关联，则将其破坏。
function c35448319.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中登记的第一个（也是唯一一个）效果对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 以效果原因将目标卡片破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 定义墓地效果的触发筛选条件：被破坏的怪兽原本在怪兽区且表侧表示，其在场上的种族包含植物族。
function c35448319.spfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and bit.band(c:GetPreviousRaceOnField(),RACE_PLANT)~=0
end
-- 特殊召唤的触发条件：被破坏的怪兽中不包含本卡自身，且存在满足植物族条件的怪兽被破坏。
function c35448319.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c35448319.spfilter,1,nil)
end
-- 特殊召唤的发动条件检查：自己主要怪兽区有空位，且这张卡自身可以被特殊召唤。
function c35448319.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定自己场上是否有可用的主要怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将本次效果处理的信息设定为‘特殊召唤’分类，对象为这张卡自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍与效果关联，将其特殊召唤；特殊召唤成功后，给它附加离场时除外（不去墓地而是除外）的效果。
function c35448319.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认卡片仍与效果关联后，以表侧表示特殊召唤这张卡到持有者场上；若召唤成功则继续。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合从游戏中除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
