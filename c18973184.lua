--失烙印
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在魔法与陷阱区域存在，包含把融合怪兽融合召唤效果的效果由自己发动的场合，那个发动不会被无效化，在那次融合召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
-- ②：自己把融合怪兽融合召唤的场合才能发动。把1只「阿不思的落胤」或者有那个卡名记述的怪兽从卡组加入手卡。
function c18973184.initial_effect(c)
	-- 记录失烙印的效果文本中记载了「阿不思的落胤」（68468459），使后续可以通过 aux.IsCodeListed 判断卡名是否记述了它。
	aux.AddCodeList(c,68468459)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，包含把融合怪兽融合召唤效果的效果由自己发动的场合，那个发动不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_INACTIVATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetValue(c18973184.efilter)
	c:RegisterEffect(e2)
	-- ①（后半）：在那次融合召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c18973184.limcon)
	e3:SetOperation(c18973184.limop)
	c:RegisterEffect(e3)
	-- ①（后半）：在那次融合召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_CHAIN_END)
	e4:SetOperation(c18973184.limop2)
	c:RegisterEffect(e4)
	-- ②：自己把融合怪兽融合召唤的场合才能发动。把1只「阿不思的落胤」或者有那个卡名记述的怪兽从卡组加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1,18973184)
	e5:SetCondition(c18973184.thcon)
	e5:SetTarget(c18973184.thtg)
	e5:SetOperation(c18973184.thop)
	c:RegisterEffect(e5)
end
-- 过滤用函数：从当前连锁中取得正在发动的效果和发动玩家，判断是否为本方发动且该效果包含融合召唤分类，用于决定是否适用“那个发动不会被无效化”。
function c18973184.efilter(e,ct)
	local p=e:GetHandlerPlayer()
	-- 获取连锁序号 ct 对应的效果对象和发动玩家，供后续判断发动者是否为这张卡的持有者。
	local te,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return p==tp and te:IsHasCategory(CATEGORY_FUSION_SUMMON)
end
-- 过滤函数：判定成功特殊召唤的怪兽是否由 tp 玩家进行融合召唤，且该融合召唤是通过包含融合召唤分类的效果处理达成的。
function c18973184.limfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_FUSION)
		and c:GetSpecialSummonInfo(SUMMON_INFO_REASON_EFFECT):IsHasCategory(CATEGORY_FUSION_SUMMON)
end
-- 条件函数：当本次特殊召唤成功的怪兽中存在至少一只满足 limfilter 的融合怪兽时，说明发生了由自己发起的融合召唤，触发①的后续处理。
function c18973184.limcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c18973184.limfilter,1,nil,tp)
end
-- 处理函数：在融合召唤成功时，根据当前是否处于连锁处理中，采取不同方式设置连锁限制，使对方不能发动魔法·陷阱·怪兽效果。
function c18973184.limop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前没有正在处理的连锁（即特殊召唤不是在连锁处理中发生的），此时直接设置直到连锁结束的封锁效果。
	if Duel.GetCurrentChain()==0 then
		-- 设置一条持续到连锁结束的连锁限制条件，禁止对方在该连锁串内发动效果。
		Duel.SetChainLimitTillChainEnd(c18973184.chainlm)
	-- 若当前正在处理的连锁数为1，说明融合召唤是连锁1处理中进行的，需要额外监听后续连锁和效果结算，以便在正确时机封锁。
	elseif Duel.GetCurrentChain()==1 then
		e:GetHandler():RegisterFlagEffect(18973184,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 在那次融合召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(c18973184.resetop)
		-- 注册监听 EVENT_CHAINING 的临时效果：若之后仍有新的效果发动，先清除融合召唤成功时设置的标记，防止封锁被错误延续。
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BREAK_EFFECT)
		e2:SetReset(RESET_CHAIN)
		-- 注册监听 EVENT_BREAK_EFFECT 的临时效果：若连锁处理中途被打断，也清除标记并取消本次限制，保证只在“那次融合召唤成功时”适用。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 复位操作：清除失烙印上的标记，并移除临时监听效果，避免后续连锁或时点误用①的封锁。
function c18973184.resetop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(18973184)
	e:Reset()
end
-- 连锁结束时的操作：若标记仍存在，则在连锁结束时也设置一次直到连锁结束的封锁限制，然后清除标记。
function c18973184.limop2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(18973184)~=0 then
		-- 设置直到连锁结束的连锁限制条件，使对方不能发动魔法·陷阱·怪兽效果。
		Duel.SetChainLimitTillChainEnd(c18973184.chainlm)
	end
	e:GetHandler():ResetFlagEffect(18973184)
end
-- 连锁限制判定：只允许当前连锁的发动者（己方）继续发动效果，对方不能发动效果。
function c18973184.chainlm(e,rp,tp)
	return tp==rp
end
-- 过滤函数：判断怪兽是否为表侧表示、是否通过融合召唤出场、且融合召唤玩家是 tp，即用于检测“自己把融合怪兽融合召唤”这一条件。
function c18973184.cfilter(c,tp)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_FUSION) and c:IsSummonPlayer(tp)
end
-- 条件函数：本次特殊召唤的怪兽中存在至少一只满足 cfilter 的融合怪兽，因此满足②的发动条件。
function c18973184.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c18973184.cfilter,1,nil,tp)
end
-- 检索目标过滤：卡必须是「阿不思的落胤」，或者是效果文本记载有「阿不思的落胤」的怪兽，并且可以被加入手牌。
function c18973184.thfilter(c)
	-- 返回是否满足检索条件：卡名是68468459，或者（是怪兽且记载有68468459），且能够加入手牌。
	return (c:IsCode(68468459) or aux.IsCodeListed(c,68468459) and c:IsType(TYPE_MONSTER)) and c:IsAbleToHand()
end
-- 效果发动时的目标处理：若卡组存在符合条件的卡则允许发动，并设置把1张卡加入手牌的操作信息。
function c18973184.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查卡组中是否存在至少1张满足 thfilter 的检索目标；若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c18973184.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向系统登记操作信息：本次效果处理将把玩家卡组中的1张卡加入手牌，供相关卡牌（如星尘龙等）进行时点判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：从卡组选择1张符合条件的怪兽加入手牌，并让对方确认。
function c18973184.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给出选择提示框，提示玩家从卡组选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己的卡组中选择1张同时满足 thfilter 的卡作为检索目标。
	local g=Duel.SelectMatchingCard(tp,c18973184.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去手牌（加入持有者手牌），原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示检索加入手牌的卡，确认检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
