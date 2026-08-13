--終刻撃針
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己主要阶段才能发动。自己的手卡·场上（表侧表示）1张其他的「终刻」卡破坏。那之后，从卡组选1只「终刻」怪兽加入手卡或特殊召唤。这个效果的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。
-- ②：这张卡被效果破坏的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏。
local s,id,o=GetID()
-- 注册三个效果：e1作为魔陷发动的基础空效果，e2为①起动效果（破坏自身手卡/场上的其他「终刻」卡并检索/特召），e3为②被效果破坏时破坏场上1只表侧表示怪兽的诱发效果。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己主要阶段才能发动。自己的手卡·场上（表侧表示）1张其他的「终刻」卡破坏。那之后，从卡组选1只「终刻」怪兽加入手卡或特殊召唤。这个效果的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"破坏并检索"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ②：这张卡被效果破坏的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"破坏怪兽"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 筛选可破坏的“其他「终刻」卡”：需为「终刻」字段且在手牌或场上表侧表示；若chk为真，还额外检查卡组是否存在可加入手卡或特殊召唤的「终刻」怪兽。
function s.cfilter(c,e,tp,chk)
	return c:IsSetCard(0x1d2) and c:IsFaceupEx()
		-- 当chk为真时，追加检查卡组中是否存在可被检索或特殊召唤的「终刻」怪兽，用于证明效果处理时后续操作可行。
		and (not chk or Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c,chk))
end
-- 筛选卡组中可被检索/特殊召唤的「终刻」怪兽：必须为「终刻」怪兽，且能够加入手卡，或当前有可用怪兽区且能够特殊召唤。
function s.thfilter(c,e,tp,ec)
	return c:IsSetCard(0x1d2) and c:IsType(TYPE_MONSTER)
		-- 满足“能加入手卡”或“有怪兽区且能特殊召唤”二者之一，即可作为检索/特召候选。
		and (c:IsAbleToHand() or (Duel.GetMZoneCount(tp,ec)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- ①效果的目标阶段：确认场上/手牌存在可破坏的“其他「终刻」卡”且卡组有可检索/特召目标；取得所有满足条件的可破坏候选卡，并向系统登记将要破坏1张卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：存在至少1张可破坏的“其他「终刻」卡”，且卡组中存在可加入手卡或特殊召唤的「终刻」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler(),e,tp,true) end
	-- 取得所有满足条件的可破坏候选卡（手卡或场上表侧表示、其他「终刻」卡），供操作信息使用。
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,e:GetHandler(),e,tp,true)
	-- 登记破坏操作信息：将破坏1张上述候选卡，category包含破坏，供相关效果（如星尘龙）检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ①效果处理：选择并破坏1张“其他「终刻」卡”；破坏成功后从卡组选1只「终刻」怪兽，根据玩家选择或条件加入手卡或特殊召唤；处理完成后施加本回合只能从额外卡组特殊召唤超量怪兽的自肃。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local dg=nil
	-- 显示“请选择要破坏的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 判断是否存在“可破坏且卡组有可检索/特召目标”的候选卡，以决定后续选择时使用的过滤参数。
	if Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil,e,tp,true) then
		-- 选择1张可破坏的“其他「终刻」卡”，要求卡组中存在可加入手卡或特殊召唤的「终刻」怪兽（chk=true），并且排除本卡自身。
		dg=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,aux.ExceptThisCard(e),e,tp,true)
	else
		-- 选择1张可破坏的“其他「终刻」卡”，不要求卡组中存在检索/特召目标（chk=false），同样排除本卡自身；作为无法按严格条件选择时的后备路径。
		dg=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,aux.ExceptThisCard(e),e,tp,false)
	end
	if dg and dg:GetCount()>0 then
		local fg=dg:Filter(Card.IsLocation,nil,LOCATION_ONFIELD)
		if fg:GetCount()>0 then
			-- 为场上被选中的破坏候选卡显示选中动画，并记录其为对象。
			Duel.HintSelection(fg)
		end
		-- 执行破坏操作；若实际破坏成功（返回值不为0），才继续后续从卡组检索/特殊召唤的处理。
		if Duel.Destroy(dg,REASON_EFFECT)~=0 then
			-- 显示“请选择要操作的卡”的提示消息。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
			-- 从卡组选择1只满足条件的「终刻」怪兽（可加入手卡或可特殊召唤）。
			local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,nil)
			-- 获取当前玩家可用的怪兽区空格数，用于判断能否特殊召唤。
			local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
			local tc=g:GetFirst()
			if tc then
				-- 中断当前效果处理，使破坏与后续检索/特召不在同一时点处理，制造时点变化。
				Duel.BreakEffect()
				-- 判断将选出的「终刻」怪兽加入手卡还是特殊召唤：若其不能特殊召唤、没有怪兽区空格，或玩家选择“加入手卡”（选项0），则加入手卡；否则特殊召唤。
				if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
					-- 将选出的「终刻」怪兽加入其持有者的手卡，原因为效果。
					Duel.SendtoHand(tc,nil,REASON_EFFECT)
					-- 向对方玩家展示加入手卡的「终刻」怪兽，确认检索内容。
					Duel.ConfirmCards(1-tp,tc)
				else
					-- 将选出的「终刻」怪兽以表侧攻击表示特殊召唤到自己场上。
					Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
				end
			end
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。②：这张卡被效果破坏的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(s.splimit)
	-- 将自肃效果注册到场上，使其作用于当前玩家（tp），持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃的过滤条件：当怪兽不是超量怪兽且位于额外卡组时，禁止该特殊召唤。
function s.splimit(e,c)
	return not c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA)
end
-- ②效果的发动条件：这张卡被效果破坏时才可发动。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT)
end
-- 取对象过滤：选择场上表侧表示怪兽。
function s.desfilter(c)
	return c:IsFaceup()
end
-- ②效果目标处理：选择场上1只表侧表示怪兽作为对象，并设置破坏该卡的操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.desfilter(chkc) end
	-- 发动时检查是否存在表侧表示怪兽可取对象。
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 显示“请选择要破坏的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1只表侧表示怪兽作为效果对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 登记破坏操作信息：将破坏所选对象怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果处理：取得对象怪兽，若其仍与连锁相关且为怪兽，则将其破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
		-- 将对象怪兽破坏，原因为效果。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
