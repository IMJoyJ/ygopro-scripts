--転生炎獣の炎陣
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。
-- ●从卡组把1只「转生炎兽」怪兽加入手卡。
-- ●以用和自身同名的怪兽为素材作连接召唤的自己场上1只「转生炎兽」连接怪兽为对象才能发动。这个回合，那只连接怪兽不受自身以外的怪兽的效果影响。
function c52155219.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：可以从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,52155219+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c52155219.target)
	e1:SetOperation(c52155219.activate)
	c:RegisterEffect(e1)
	if not c52155219.global_check then
		c52155219.global_check=true
		-- 以用和自身同名的怪兽为素材作连接召唤的自己场上1只「转生炎兽」连接怪兽为对象才能发动。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
		ge1:SetCode(EFFECT_MATERIAL_CHECK)
		ge1:SetValue(c52155219.valcheck)
		-- 将EFFECT_MATERIAL_CHECK效果作为全局效果注册到全场，使每次怪兽作为素材出场时都执行c52155219.valcheck，用来标记“用同名怪兽为素材作连接召唤”的转生炎兽连接怪兽。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 该函数是素材检查回调：当怪兽出场并拥有素材时，若素材组中存在与该怪兽卡号相同（同名）的素材，则给该怪兽注册52155219号flag，用于标记它是以同名怪兽为素材进行连接召唤的转生炎兽连接怪兽。
function c52155219.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsLinkCode,1,nil,c:GetCode()) then
		c:RegisterFlagEffect(52155219,RESET_EVENT+0x4fe0000,0,1)
	end
end
-- 检索过滤器：筛选出属于“转生炎兽”系列的怪兽，且该怪兽能够被加入手牌。
function c52155219.thfilter(c)
	return c:IsSetCard(0x119) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 免疫对象过滤器：筛选出表侧表示、属于“转生炎兽”系列、以连接召唤方式出场、且带有52155219标记的转生炎兽连接怪兽。
function c52155219.immfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x119) and c:IsSummonType(SUMMON_TYPE_LINK) and c:GetFlagEffect(52155219)~=0
end
-- 发动前的条件判定与选目标函数：分别检查两个分支是否可用；若两个分支都可用则让玩家选择要发动的分支；之后根据选择保存op标签，并设置对应效果类别、取对象属性及选择对象（若选择免疫分支）。
function c52155219.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c52155219.immfilter(chkc) end
	-- 检查卡组中是否存在至少1张满足thfilter的“转生炎兽”怪兽，用于决定能否选择“从卡组加入手卡”的分支。
	local b1=Duel.IsExistingMatchingCard(c52155219.thfilter,tp,LOCATION_DECK,0,1,nil)
	-- 检查自己场上是否存在至少1只满足immfilter且能够成为效果对象的“转生炎兽”连接怪兽，用于决定能否选择“效果抗性”的分支。
	local b2=Duel.IsExistingTarget(c52155219.immfilter,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 当两个分支都可用时，弹出“卡组检索/效果抗性”两个选项供玩家选择，返回的选项序号作为op保存，用于后续分支处理。
		op=Duel.SelectOption(tp,aux.Stringid(52155219,0),aux.Stringid(52155219,1))  --"卡组检索/效果抗性"
	elseif b1 then
		-- 当只有检索分支可用时，仅显示“卡组检索”选项，选择后op为0。
		op=Duel.SelectOption(tp,aux.Stringid(52155219,0))  --"卡组检索"
	else
		-- 当只有效果抗性分支可用时，仅显示“效果抗性”选项，并通过+1使op为1，保持与其他分支的op值含义一致。
		op=Duel.SelectOption(tp,aux.Stringid(52155219,1))+1  --"效果抗性"
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e:SetProperty(0)
		-- 设置操作信息为“从卡组将1张卡加入手卡”（目标未定，不取对象），供星尘龙、王家长眠之谷等相关效果检测本次检索/回手行为。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	else
		e:SetCategory(0)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		-- 向玩家显示“请选择表侧表示的卡”的选择提示，为接下来的取对象选择做准备。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 从自己场上选择1只满足immfilter的转生炎兽连接怪兽作为效果对象，并将该对象与当前连锁关联。
		Duel.SelectTarget(tp,c52155219.immfilter,tp,LOCATION_MZONE,0,1,1,nil)
	end
end
-- 效果处理函数：若op为0，则从卡组选择1只转生炎兽怪兽加入手牌并给对方确认；若op为1，则给对象怪兽赋予“这个回合不受自身以外的怪兽效果影响”的免疫效果。
function c52155219.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==0 then
		-- 显示“请选择要加入手牌的卡”的提示，提示玩家从卡组选卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组中选择1只满足thfilter的转生炎兽怪兽。
		local g=Duel.SelectMatchingCard(tp,c52155219.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的怪兽以效果原因加入其持有者手牌。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 将检索到的卡展示给对方玩家确认。
			Duel.ConfirmCards(1-tp,g)
		end
	else
		-- 取得当前连锁中记录的第一张对象卡，即免疫分支选择的那只转生炎兽连接怪兽。
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 这个回合，那只连接怪兽不受自身以外的怪兽效果影响。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_IMMUNE_EFFECT)
			e1:SetValue(c52155219.efilter)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	end
end
-- 免疫判定函数：当效果来源不是获得免疫的怪兽自身，并且该效果是怪兽效果时，返回true，使该怪兽不受此效果影响；即实现“自身以外的怪兽效果影响”的判定。
function c52155219.efilter(e,re)
	return e:GetHandler()~=re:GetOwner() and re:IsActiveType(TYPE_MONSTER)
end
