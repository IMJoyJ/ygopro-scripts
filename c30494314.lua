--紅血鬼
-- 效果：
-- 这张卡用不死族怪兽的效果从墓地的特殊召唤成功时，选择自己场上1只不死族怪兽才能发动。把场上1个超量素材取除，选择的怪兽的等级上升1星，攻击力上升300。
function c30494314.initial_effect(c)
	-- 创建一个诱发选发效果，用于处理特殊召唤成功时的触发条件和效果执行
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
-- 判断此卡是否由墓地特殊召唤成功且召唤者为不死族怪兽
function c30494314.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local typ,race=c:GetSpecialSummonInfo(SUMMON_INFO_TYPE,SUMMON_INFO_RACE)
	return c:IsPreviousLocation(LOCATION_GRAVE) and typ&TYPE_MONSTER~=0 and race&RACE_ZOMBIE~=0
end
-- 过滤场上正面表示的不死族怪兽
function c30494314.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:IsLevelAbove(0)
end
-- 设置效果的目标选择条件，确保能选择到符合条件的不死族怪兽
function c30494314.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c30494314.filter(chkc) end
	-- 检查是否能移除场上的一个超量素材
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,1,1,REASON_EFFECT)
		-- 检查场上是否存在符合条件的不死族怪兽作为效果对象
		and Duel.IsExistingTarget(c30494314.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家提示选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上符合条件的不死族怪兽作为效果对象
	Duel.SelectTarget(tp,c30494314.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 执行效果的处理流程，包括取除超量素材并提升目标怪兽的等级和攻击力
function c30494314.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要取除超量素材的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEATTACHFROM)  --"请选择要取除超量素材的怪兽"
	-- 选择场上满足条件的怪兽并移除其一个超量素材
	local sg=Duel.SelectMatchingCard(tp,Card.CheckRemoveOverlayCard,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp,1,REASON_EFFECT)
	if sg:GetCount()==0 then return end
	sg:GetFirst():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 使目标怪兽的等级上升1星
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 使目标怪兽的攻击力上升300
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(300)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
