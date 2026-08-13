--紅血鬼
-- 效果：
-- 这张卡用不死族怪兽的效果从墓地的特殊召唤成功时，选择自己场上1只不死族怪兽才能发动。把场上1个超量素材取除，选择的怪兽的等级上升1星，攻击力上升300。
function c30494314.initial_effect(c)
	-- 这张卡用不死族怪兽的效果从墓地的特殊召唤成功时，选择自己场上1只不死族怪兽才能发动。把场上1个超量素材取除，选择的怪兽的等级上升1星，攻击力上升300。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30494314,0))  --"等级攻击上升"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c30494314.condition)
	e1:SetTarget(c30494314.target)
	e1:SetOperation(c30494314.operation)
	c:RegisterEffect(e1)
end
-- 发动条件判定：本卡必须是从墓地特殊召唤成功，且该特殊召唤是由不死族怪兽的效果进行的（通过特殊召唤信息的类型为怪兽、种族为不死族判断）。
function c30494314.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local typ,race=c:GetSpecialSummonInfo(SUMMON_INFO_TYPE,SUMMON_INFO_RACE)
	return c:IsPreviousLocation(LOCATION_GRAVE) and typ&TYPE_MONSTER~=0 and race&RACE_ZOMBIE~=0
end
-- 筛选可作为效果对象的怪兽：自己场上的表侧表示不死族怪兽，且等级/阶级为0以上（此条件通常恒真）。
function c30494314.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:IsLevelAbove(0)
end
-- 效果发动前的目标判定与选择：先检查是否有可因效果取除的超量素材以及是否有可选的自己场上不死族怪兽；在发动时选择自己场上1只不死族怪兽作为对象。
function c30494314.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c30494314.filter(chkc) end
	-- 发动合法性检查：确认场上存在至少1个可以因‘效果’原因被取除的超量素材。
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,1,1,REASON_EFFECT)
		-- 同时确认自己场上存在至少1只满足c30494314.filter条件的表侧表示不死族怪兽，可以作为效果对象。
		and Duel.IsExistingTarget(c30494314.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 给玩家显示‘请选择效果的对象’的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己场上选择1只符合条件的不死族怪兽作为效果对象，并将其登记为当前连锁的对象。
	Duel.SelectTarget(tp,c30494314.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：从场上选择1只可被取除超量素材的怪兽，取除其1个超量素材；然后对之前选择的目标怪兽，若仍表侧表示且与效果关联，则令其等级上升1星、攻击力上升300，且这些数值变化不会被无效化，并随标准重置条件消失。
function c30494314.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家显示‘请选择要取除超量素材的怪兽’的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEATTACHFROM)  --"请选择要取除超量素材的怪兽"
	-- 从双方怪兽区域选择1只能够因效果取除超量素材的怪兽（由当前玩家取除1张，原因为效果）。
	local sg=Duel.SelectMatchingCard(tp,Card.CheckRemoveOverlayCard,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp,1,REASON_EFFECT)
	if sg:GetCount()==0 then return end
	sg:GetFirst():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	-- 取得发动时选择的不死族怪兽对象，即当前连锁的取对象卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 选择的怪兽的等级上升1星
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 选择的怪兽的攻击力上升300
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(300)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
