--エヴォルダー・ダルウィノス
-- 效果：
-- 这张卡用名字带有「进化虫」的怪兽的效果特殊召唤成功时，可以选择场上表侧表示存在的1只怪兽等级上升最多2星。
function c39672388.initial_effect(c)
	-- 这张卡用名字带有「进化虫」的怪兽的效果特殊召唤成功时，可以选择场上表侧表示存在的1只怪兽等级上升最多2星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39672388,0))  --"等级上升"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	-- 设置效果的发动条件：仅当此卡用名字带有「进化虫」的怪兽的效果特殊召唤成功时，该效果才能发动。
	e1:SetCondition(aux.evospcon)
	e1:SetTarget(c39672388.lvtg)
	e1:SetOperation(c39672388.lvop)
	c:RegisterEffect(e1)
end
-- 定义选择对象的过滤条件：必须是表侧表示且等级为0以上的怪兽（即所有表侧表示的怪兽都符合条件）。
function c39672388.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(0)
end
-- 效果发动时的取对象处理：选择场上表侧表示存在的1只怪兽作为对象；若在连锁中指定对象则直接判断该卡是否满足条件，若为发动前检测则检查是否存在符合条件的对象。
function c39672388.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c39672388.filter(chkc) end
	-- 效果发动合法性检查：确认场上是否存在至少1只满足条件的表侧表示怪兽，存在才可发动。
	if chk==0 then return Duel.IsExistingTarget(c39672388.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发出选择表侧表示怪兽的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从双方怪兽区选择1只表侧表示怪兽作为效果对象，并将该卡登记为当前连锁的对象。
	Duel.SelectTarget(tp,c39672388.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理时的操作：获取对象，若对象仍与效果相关且表侧表示，则让玩家选择上升1星或2星，并赋予对象怪兽对应的等级上升效果。
function c39672388.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 让玩家选择等级上升1星还是上升2星，对应效果原文的“最多2星”。
		local opt=Duel.SelectOption(tp,aux.Stringid(39672388,1),aux.Stringid(39672388,2))  --"等级上升１星/等级上升２星"
		-- 为对象怪兽创建一个永续的等级上升效果：不可被无效，上升星数为玩家选择的数值（opt+1，即1或2），并在卡片离场、回合结束等标准重置时机失效。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(opt+1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
