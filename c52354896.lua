--斬機マルチプライヤー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只电子界族·4星怪兽为对象才能发动。那只怪兽的等级直到回合结束时变成8星。
-- ②：这张卡被送去墓地的场合，以额外怪兽区域1只自己的电子界族怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成2倍。
function c52354896.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：以自己场上1只电子界族·4星怪兽为对象才能发动。那只怪兽的等级直到回合结束时变成8星。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,52354896)
	e1:SetTarget(c52354896.target)
	e1:SetOperation(c52354896.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合，以额外怪兽区域1只自己的电子界族怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成2倍。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,52354897)
	e2:SetTarget(c52354896.datg)
	e2:SetOperation(c52354896.daop)
	c:RegisterEffect(e2)
end
-- 筛选条件：对象必须是表侧表示、等级为4且种族为电子界的怪兽，用于①效果选择对象时过滤合法目标。
function c52354896.filter(c)
	return c:IsFaceup() and c:IsLevel(4) and c:IsRace(RACE_CYBERSE)
end
-- ①效果的发动条件与对象选择：若有指定对象则校验其合法性；若无指定则在发动确认时检查场上是否存在合法对象；然后提示玩家选择自己场上1只表侧表示的4星电子界族怪兽，并将其设为效果对象。
function c52354896.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c52354896.filter(chkc) end
	-- 发动合法性检查（chk==0）：确认自己场上是否存在至少1只满足条件的表侧表示4星电子界族怪兽，存在才能发动。
	if chk==0 then return Duel.IsExistingTarget(c52354896.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向操作玩家显示“请选择表侧表示的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让操作玩家从自己场上选择1只满足条件的表侧表示4星电子界族怪兽作为效果对象，并登记为当前连锁的对象。
	Duel.SelectTarget(tp,c52354896.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ①效果处理：获取发动时选择的对象，若对象仍表侧表示且与效果关联，则给它赋予一个使等级变为8的效果，该效果持续到回合结束。
function c52354896.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取①效果发动时所选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的等级直到回合结束时变成8星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(8)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 筛选条件：对象必须是表侧表示、种族为电子界且位于额外怪兽区域（区域序号>=5）的怪兽，用于②效果选择对象时过滤合法目标。
function c52354896.dafilter(c)
	return c:IsFaceup() and c:IsRace(RACE_CYBERSE) and c:GetSequence()>=5
end
-- ②效果的发动条件与对象选择：若有指定对象则校验其合法性；若无指定则在发动确认时检查额外怪兽区域是否存在合法对象；然后提示玩家选择额外怪兽区域1只自己的表侧表示电子界族怪兽，并将其设为效果对象。
function c52354896.datg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c52354896.dafilter(chkc) end
	-- 发动合法性检查（chk==0）：确认自己的额外怪兽区域是否存在至少1只满足条件的表侧表示电子界族怪兽，存在才能发动。
	if chk==0 then return Duel.IsExistingTarget(c52354896.dafilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向操作玩家显示“请选择表侧表示的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让操作玩家从自己的额外怪兽区域选择1只满足条件的表侧表示电子界族怪兽作为效果对象，并登记为当前连锁的对象。
	Duel.SelectTarget(tp,c52354896.dafilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果处理：获取发动时选择的对象，若对象仍与效果关联且表侧表示，则将它的攻击力变成当前攻击力的2倍，该效果持续到回合结束。
function c52354896.daop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②效果发动时所选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local atk=tc:GetAttack()
		-- 那只怪兽的攻击力直到回合结束时变成2倍。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(atk*2)
		tc:RegisterEffect(e1)
	end
end
