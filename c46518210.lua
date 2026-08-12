--溟界神－ネフェルアビス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在墓地存在的状态，从自己或对方的手卡·卡组有怪兽被送去墓地的场合才能发动。这张卡特殊召唤。这个效果的发动后，直到下个回合的结束时自己不是爬虫类族怪兽不能特殊召唤。
-- ②：这张卡是已从墓地特殊召唤的场合，以「溟界神-涅斐尔阿比斯」以外的自己墓地1只怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片的两个效果，分别为①和②效果
function s.initial_effect(c)
	-- 为卡片注册一个监听送入墓地事件的单次持续效果，用于判断是否满足①效果发动条件
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- 设置①效果的描述、分类、类型、触发时点、适用区域、使用次数限制、属性、标签对象、发动条件、目标选择函数和处理函数
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetLabelObject(e0)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 设置②效果的描述、分类、类型、适用区域、使用次数限制、属性、发动条件、目标选择函数和处理函数
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(s.gscon)
	e2:SetTarget(s.gstg)
	e2:SetOperation(s.gsop)
	c:RegisterEffect(e2)
end
-- 定义用于筛选被送去墓地的怪兽的过滤器，确保是来自手牌或卡组的怪兽且不是由当前效果送入墓地
function s.cfilter(c,se)
	return c:IsType(TYPE_MONSTER) and c:IsPreviousLocation(LOCATION_DECK+LOCATION_HAND)
		and (se==nil or c:GetReasonEffect()~=se)
end
-- 判断是否满足①效果发动条件，即是否有怪兽从手牌或卡组送去墓地且不是由当前效果送入
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.cfilter,1,e:GetHandler(),se)
end
-- 设置①效果的目标选择函数，检查是否可以特殊召唤自身
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查场上是否有足够的特殊召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将要特殊召唤卡片
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 设置①效果的处理函数，执行特殊召唤并施加不能特殊召唤非爬虫类族怪兽的效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断卡片是否与效果相关联，若关联则进行特殊召唤
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
	-- 创建并注册一个影响玩家的永续效果，禁止在指定回合内特殊召唤非爬虫类族怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splim)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 将效果e1注册给玩家tp
	Duel.RegisterEffect(e1,tp)
end
-- 定义禁止特殊召唤非爬虫类族怪兽的效果目标函数
function s.splim(e,c)
	return not c:IsRace(RACE_REPTILE)
end
-- 判断②效果是否满足发动条件，即卡片是否从墓地特殊召唤过
function s.gscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonLocation(LOCATION_GRAVE)
end
-- 定义用于筛选墓地怪兽的过滤器，确保可以被特殊召唤且不是自身
function s.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
end
-- 设置②效果的目标选择函数，检查是否有符合条件的墓地怪兽可作为目标
function s.gstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	-- 检查场上是否有足够的特殊召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在符合条件的墓地怪兽作为目标
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽并设置为当前连锁的目标
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，表示将要特殊召唤目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 设置②效果的处理函数，执行目标怪兽的特殊召唤
function s.gsop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡片
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡片是否与效果相关联，若关联则进行特殊召唤
	if tc:IsRelateToEffect(e) then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
end
