--バーサーク・デーモン
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：以包含恶魔族怪兽的自己场上最多2只表侧表示怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽破坏。
-- ②：这张卡的①的效果破坏怪兽时，以那个数量的对方场上的表侧表示怪兽为对象才能发动。这张卡的攻击力直到下次的自己回合的结束时上升作为对象的怪兽的原本攻击力的合计数值。
local s,id,o=GetID()
-- 创建并注册狂战恶魔的两个效果：①为手牌起动效果，特殊召唤自身并破坏对象怪兽；②为场上诱发效果，在①效果破坏怪兽后上升攻击力。同时设置效果描述、分类、类型、属性、范围、次数限制及相关函数。
function s.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：以包含恶魔族怪兽的自己场上最多2只表侧表示怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"这张卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡的①的效果破坏怪兽时，以那个数量的对方场上的表侧表示怪兽为对象才能发动。这张卡的攻击力直到下次的自己回合的结束时上升作为对象的怪兽的原本攻击力的合计数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"攻击力上升"
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CUSTOM+id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.atkcon)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
-- ①效果选择对象的筛选条件：必须是表侧表示的怪兽，并且能够成为当前效果的对象。
function s.cfilter(c,e)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e)
end
-- 子组选择条件：从候选怪兽中选出的怪兽组里必须至少包含1只恶魔族怪兽，以满足①效果“包含恶魔族怪兽”的发动要求。
function s.fselect(g)
	return g:IsExists(Card.IsRace,1,nil,RACE_FIEND)
end
-- ①效果的发动条件和对象选择：先获取自己场上可成为对象的表侧表示怪兽，再检查主要怪兽区有空位、手牌的这张卡能够特殊召唤，并且存在1～2只含恶魔族的可选组合；满足后进入选择对象阶段。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取自己场上全部满足条件的表侧表示怪兽（能被当前效果对象化），作为①效果选择对象的候选池。
	local rg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil,e)
	-- 效果发动时（chk==0）检查自己主要怪兽区是否有空位，确保这张卡可以从手牌特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) and rg:CheckSubGroup(s.fselect,1,2) end
	-- 给玩家显示选择对象的提示信息，提示文字为“请选择效果的对象”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local sg=rg:SelectSubGroup(tp,s.fselect,false,1,2)
	-- 将玩家选择的1～2只怪兽组设为当前连锁的对象，用于后续特殊召唤成功后的破坏处理。
	Duel.SetTargetCard(sg)
	-- 设置操作信息：声明本连锁将进行1只怪兽的特殊召唤（即这张卡），供需要检测这类操作的效果（如星尘龙等）使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：取回对象怪兽；若这张卡仍与效果关联且特殊召唤成功，则破坏那些对象怪兽；若实际破坏了怪兽，则触发自定义事件，将破坏数量传递给②效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取回①效果发动时选择的对象怪兽组（用于破坏）。
	local tg=Duel.GetTargetsRelateToChain()
	-- 确认这张卡仍与效果关联，并尝试将其以表侧攻击表示特殊召唤到自己场上；只有特殊召唤成功才继续执行破坏。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 以效果原因破坏之前选择的对象怪兽，并保存实际破坏数量dt，用于②效果可选择的对方怪兽数量。
		local dt=Duel.Destroy(tg,REASON_EFFECT)
		if dt>0 then
			-- 以这张卡为触发源触发自定义事件（EVENT_CUSTOM+id），事件参数中包含破坏数量dt；②效果监听到该事件后可在满足条件时发动。
			Duel.RaiseEvent(c,EVENT_CUSTOM+id,re,r,tp,ep,dt)
		end
	end
end
-- ②效果的发动条件：事件必须由自己回合发动的①效果产生，且事件触发组中包含这张卡（即这张卡的①效果破坏了怪兽）。
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return tp==rp and eg and eg:IsContains(e:GetHandler())
end
-- ②效果选择对象的筛选条件：对方场上的表侧表示怪兽，且原本攻击力大于0。
function s.atkfilter(c)
	return c:IsFaceup() and c:GetBaseAttack()>0
end
-- ②效果的目标选择：在效果发动时确认对方场上存在至少ev只符合条件的怪兽，然后提示玩家选择恰好ev只（即①效果破坏数量）作为攻击力上升的对象。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.atkfilter(chkc) end
	-- 效果发动时（chk==0）检查对方场上是否存在至少ev只表侧表示且原本攻击力大于0的怪兽，以决定②效果能否发动。
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,0,LOCATION_MZONE,ev,nil) end
	-- 给玩家显示选择对象的提示信息，提示文字为“请选择效果的对象”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 强制玩家从对方场上选择ev只符合条件的表侧表示怪兽作为②效果的对象，并设置为当前连锁的对象。
	Duel.SelectTarget(tp,s.atkfilter,tp,0,LOCATION_MZONE,ev,ev,nil)
end
-- ②效果处理：取回对象怪兽，计算它们原本攻击力的合计值；若这张卡仍与效果关联且表侧表示，则给予其直到下次自己回合结束时的攻击力上升效果，上升值为该合计值。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取回②效果发动时选择的对方怪兽组，用于计算合计原本攻击力。
	local tg=Duel.GetTargetsRelateToChain()
	local atk=tg:GetSum(Card.GetBaseAttack)
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力直到下次的自己回合的结束时上升作为对象的怪兽的原本攻击力的合计数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(atk)
		c:RegisterEffect(e1)
	end
end
