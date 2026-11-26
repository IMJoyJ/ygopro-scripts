--終刻撃針
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己主要阶段才能发动。自己的手卡·场上（表侧表示）1张其他的「终刻」卡破坏。那之后，从卡组选1只「终刻」怪兽加入手卡或特殊召唤。这个效果的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。
-- ②：这张卡被效果破坏的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏。
local s,id,o=GetID()
-- 初始化卡片效果：注册永续魔法卡的发动效果，并注册共享1回合1次限制的①效果（破坏己方其他「终刻」卡并从卡组检索或特召「终刻」怪兽）与②效果（被效果破坏时炸场上1只表侧怪兽）
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。 ①：自己主要阶段才能发动。自己的手卡·场上（表侧表示）1张其他的「终刻」卡破坏。那之后，从卡组选1只「终刻」怪兽加入手卡或特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"破坏并检索"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
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
-- 筛选条件：检查卡片是否为手卡或场上表侧表示的「终刻」卡，并在需要检测后续操作时确认卡组存在对应可检索或可特召的「终刻」怪兽
function s.cfilter(c,e,tp,chk)
	return c:IsSetCard(0x1d2) and c:IsFaceupEx()
		-- 若处于发动检测阶段，则进一步确认己方卡组存在可加入手卡或在破坏该卡后可特殊召唤的「终刻」怪兽
		and (not chk or Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c,chk))
end
-- 筛选条件：检查卡片是否为「终刻」怪兽，且可加入手卡或在破坏对象离场后有空位时可特殊召唤
function s.thfilter(c,e,tp,ec)
	return c:IsSetCard(0x1d2) and c:IsType(TYPE_MONSTER)
		-- 检查该怪兽是否能够加入手卡，或者在破坏对象离场后己方怪兽区有空位时能够特殊召唤
		and (c:IsAbleToHand() or (Duel.GetMZoneCount(tp,ec)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- ①效果的发动检测与连锁信息设置：确认己方手卡·场上存在其他满足条件的「终刻」卡，并登记破坏操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认己方手卡·场上存在这张卡以外至少1张可破坏并联动卡组检索或特召的「终刻」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler(),e,tp,true) end
	-- 获取己方手卡与场上除自身外所有符合条件的「终刻」卡片组
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,e:GetHandler(),e,tp,true)
	-- 登记连锁的破坏操作信息，预计破坏1张满足条件的「终刻」卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ①效果的处理流程：破坏己方手卡·场上1张其他「终刻」卡，再从卡组选1只「终刻」怪兽加手或特召，并施加本回合只能从额外卡组特召超量怪兽的限制
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local dg=nil
	-- 向己方提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 检查是否存在能同时满足后续卡组检索或特召条件的己方手卡·场上「终刻」卡
	if Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil,e,tp,true) then
		-- 优先让己方从手卡·场上（除自身外）选择1张破坏后可联动卡组操作的「终刻」卡
		dg=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,aux.ExceptThisCard(e),e,tp,true)
	else
		-- 若当前无满足卡组联动条件的卡，则退而从手卡·场上（除自身外）选择1张「终刻」卡
		dg=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,aux.ExceptThisCard(e),e,tp,false)
	end
	if dg and dg:GetCount()>0 then
		local fg=dg:Filter(Card.IsLocation,nil,LOCATION_ONFIELD)
		if fg:GetCount()>0 then
			-- 高亮提示在场上被选为破坏目标的卡片
			Duel.HintSelection(fg)
		end
		-- 以效果破坏所选「终刻」卡，并判断是否破坏成功
		if Duel.Destroy(dg,REASON_EFFECT)~=0 then
			-- 向己方提示选择要从卡组操作的「终刻」怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
			-- 让己方从己方卡组选择1只可加入手卡或特殊召唤的「终刻」怪兽
			local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,nil)
			-- 获取当前己方主要怪兽区的可用空位数
			local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
			local tc=g:GetFirst()
			if tc then
				-- 中断效果处理，使后续加手或特殊召唤与前面的破坏视为不同时处理
				Duel.BreakEffect()
				-- 若该怪兽能加入手卡，且无法特殊召唤、场上无空位或己方选择加入手卡分支，则执行加入手卡
				if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
					-- 以效果将所选「终刻」怪兽加入己方手卡
					Duel.SendtoHand(tc,nil,REASON_EFFECT)
					-- 向对方展示加入手卡的「终刻」怪兽
					Duel.ConfirmCards(1-tp,tc)
				else
					-- 将所选「终刻」怪兽以表侧表示特殊召唤到己方场上
					Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
				end
			end
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(s.splimit)
	-- 为己方玩家注册持续至回合结束时的额外卡组特殊召唤限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制过滤函数：禁止从额外卡组特殊召唤非超量怪兽
function s.splimit(e,c)
	return not c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA)
end
-- ②效果的发动条件检查：确认这张卡是因效果被破坏的
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT)
end
-- 筛选条件：检查场上卡片是否为表侧表示
function s.desfilter(c)
	return c:IsFaceup()
end
-- ②效果的发动检测、取对象及信息设置：确认双方怪兽区存在表侧怪兽，选择1只作为对象并登记破坏操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.desfilter(chkc) end
	-- 发动条件检查：确认双方场上存在至少1只可成为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向己方提示选择要破坏的对象怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让己方从双方场上选择1只表侧表示怪兽作为破坏对象
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 登记连锁的破坏操作信息，预计破坏所选对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果的处理流程：确认对象怪兽仍与连锁有联系且为怪兽后将其破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁所指定的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
		-- 以效果将对象怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
