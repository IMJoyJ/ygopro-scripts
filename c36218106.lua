--寡黙なるサイコミニスター
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己场上有「寡默的念力牧师」以外的念动力族怪兽存在的场合，这张卡可以从手卡守备表示特殊召唤。
-- ②：从自己墓地把这张卡和1只念动力族怪兽除外，以场上1只表侧表示怪兽为对象才能发动。那只怪兽直到结束阶段除外。
local s,id,o=GetID()
-- 注册①的规则特殊召唤效果（从手卡守备表示特殊召唤，1回合1次）和②的起动效果（除外墓地自身和1只念动力族怪兽，取对象除外场上表侧表示怪兽直到结束阶段）。
function s.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次，①：自己场上有「寡默的念力牧师」以外的念动力族怪兽存在的场合，这张卡可以从手卡守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetTargetRange(POS_FACEUP_DEFENSE,0)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.sprcon)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：从自己墓地把这张卡和1只念动力族怪兽除外，以场上1只表侧表示怪兽为对象才能发动。那只怪兽直到结束阶段除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.rmcost)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end
-- ①特殊召唤条件的过滤：判断怪兽是表侧表示、念动力族且不是「寡默的念力牧师」自身。
function s.sprfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO) and not c:IsCode(id)
end
-- ①特殊召唤的规则条件：若查询是否存在可特殊召唤的卡则返回真；否则需要自己主要怪兽区有空位，且场上存在其他表侧表示的念动力族怪兽。
function s.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的主要怪兽区空位，以满足从手卡特殊召唤的基本条件。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在满足s.sprfilter的怪兽，即表侧表示、念动力族且不是「寡默的念力牧师」的怪兽，用于①的条件。
		and Duel.IsExistingMatchingCard(s.sprfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ②代价的过滤：判断墓地中的卡是念动力族怪兽且可以作为代价除外。
function s.cfilter(c)
	return c:IsRace(RACE_PSYCHO) and c:IsAbleToRemoveAsCost()
end
-- ②发动代价的检查：这张卡自身能够作为代价除外，并且墓地存在1只可作为代价的念动力族怪兽。
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 检查墓地是否存在1只满足条件的念动力族怪兽（排除这张卡自身）可以作为代价。
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 向玩家显示“请选择要除外的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1只念动力族怪兽（排除自身）作为代价，返回选中的卡组。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	g:AddCard(e:GetHandler())
	-- 将选中的代价怪兽（连同这张卡自身）以表侧表示除外，作为效果发动的代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②取对象的过滤：判断场上怪兽是否是表侧表示且可以被除外。
function s.rmfilter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
-- ②目标选择：选择场上1只表侧表示怪兽作为对象，并登记将除外的操作信息。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.rmfilter(chkc) end
	-- 检查场上是否存在可以作为这张卡效果对象的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 显示“请选择要除外的卡”的选择提示（用于选择对象）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从双方场上选择1只表侧表示怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁的操作信息：将对象怪兽以除外处理（数量1），以便其他卡进行对应。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ②效果处理：将对象怪兽从场上暂时除外，并在结束阶段将其返回；同时给该怪兽设置标记防止重复。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若对象是仍与连锁相关的怪兽，则以表侧表示将其暂时除外；判定成功后才继续。
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)>0 then
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		-- 那只怪兽直到结束阶段除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetCondition(s.retcon)
		e1:SetOperation(s.retop)
		-- 注册一个持续效果，在结束阶段将暂时除外的对象怪兽返回场上。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 返回条件：若对象怪兽带有之前设置的暂时除外标记，则在结束阶段执行返回。
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetFlagEffect(id)>0
end
-- 返回操作：把暂时除外的对象怪兽送回场上。
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将对象怪兽返回场上（表示形式和区域按离场前状态处理）。
	Duel.ReturnToField(e:GetLabelObject())
end
