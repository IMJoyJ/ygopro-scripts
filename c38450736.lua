--甲虫装機 ウィーグ
-- 效果：
-- 1回合1次，可以从自己的手卡·墓地把1只名字带有「甲虫装机」的怪兽当作装备卡使用给这张卡装备。这张卡当作装备卡使用而装备中的场合，装备怪兽的攻击力·守备力上升这张卡的各自数值。此外，给怪兽装备的这张卡被送去墓地时，装备过的怪兽的攻击力直到结束阶段时上升1000。
function c38450736.initial_effect(c)
	-- 1回合1次，可以从自己的手卡·墓地把1只名字带有「甲虫装机」的怪兽当作装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetDescription(aux.Stringid(38450736,0))  --"装备"
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c38450736.eqtg)
	e1:SetOperation(c38450736.eqop)
	c:RegisterEffect(e1)
	-- 这张卡当作装备卡使用而装备中的场合，装备怪兽的攻击力上升这张卡的攻击力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(1000)
	c:RegisterEffect(e2)
	-- 这张卡当作装备卡使用而装备中的场合，装备怪兽的守备力上升这张卡的守备力数值。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(1000)
	c:RegisterEffect(e3)
	-- 此外，给怪兽装备的这张卡被送去墓地时，装备过的怪兽的攻击力直到结束阶段时上升1000。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(38450736,1))  --"攻击上升"
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c38450736.atkcon)
	e3:SetTarget(c38450736.atktg)
	e3:SetOperation(c38450736.atkop)
	c:RegisterEffect(e3)
end
-- 过滤出名字带有「甲虫装机」且为怪兽卡、未被禁止的卡，作为可从手卡·墓地选择装备的对象。
function c38450736.filter(c)
	return c:IsSetCard(0x56) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- 发动条件判定：自己的魔法与陷阱区域有空位，且手卡·墓地存在至少1只满足条件的「甲虫装机」怪兽。
function c38450736.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测自己的魔法与陷阱区域是否有可用的空格，若没有则无法发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检测手卡·墓地是否存在至少1只名字带有「甲虫装机」的怪兽（可被选择为装备卡）。
		and Duel.IsExistingMatchingCard(c38450736.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil) end
	-- 设置操作信息：本次效果可能使1张卡离开墓地·手卡（墓地侧受王家长眠之谷等效果制约），以便其他效果正确响应。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 效果处理：再次确认魔陷区有空位且自身仍表侧表示并与效果关联；从手卡·墓地选择1只符合条件的「甲虫装机」怪兽（排除王家长眠之谷影响）装备给自己，并为装备怪兽附加只能装备给本卡的限制。
function c38450736.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时若自己魔法与陷阱区域没有空位，则无法进行装备，直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 向操作玩家显示选择装备卡的提示信息，提示内容为“请选择要装备的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从手卡·墓地中选择1只满足filter且不受王家长眠之谷影响的「甲虫装机」怪兽作为装备卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c38450736.filter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽卡作为装备卡装备给本卡；若装备成功则继续，否则终止处理。
		if not Duel.Equip(tp,tc,c) then return end
		-- 对应原文“当作装备卡使用给这张卡装备”——给被选择的装备卡附加装备对象限制，使其只能装备给这张卡（效果持有者）。
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c38450736.eqlimit)
		tc:RegisterEffect(e1)
	end
end
-- 装备限制回调：仅当目标怪兽为效果持有者（本卡）时允许装备，确保装备卡只能装备给这张卡。
function c38450736.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 触发条件：这张卡作为装备卡离场并送去墓地，且其装备怪兽仍在场上表侧表示时，记录该装备怪兽并触发上升攻击力的效果。
function c38450736.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	e:SetLabelObject(ec)
	return ec and c:IsLocation(LOCATION_GRAVE) and ec:IsFaceup() and ec:IsLocation(LOCATION_MZONE)
end
-- 触发效果的对象设定：该效果为必发，发动时返回true，并将记录的装备怪兽设为本次效果的对象。
function c38450736.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ec=e:GetLabelObject()
	-- 将装备过的怪兽登记为当前连锁的对象，确保后续处理时能正确判断其与效果关联。
	Duel.SetTargetCard(ec)
end
-- 效果处理：若装备过的怪兽仍在场上表侧表示且与效果关联，则给它附加一个直到结束阶段攻击力上升1000的效果。
function c38450736.atkop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetLabelObject()
	if ec:IsLocation(LOCATION_MZONE) and ec:IsFaceup() and ec:IsRelateToEffect(e) then
		-- 装备过的怪兽的攻击力直到结束阶段时上升1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		ec:RegisterEffect(e1)
	end
end
