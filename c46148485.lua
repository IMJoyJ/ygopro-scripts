--転輪のスフィンクス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：怪兽的表示形式变更的场合，从自己墓地把1张魔法卡除外才能发动。这张卡从手卡·墓地特殊召唤。
-- ②：自己主要阶段才能发动。从自己的卡组·墓地把「太阳之书」和「月之书」各最多1张在自己的魔法与陷阱区域盖放。
-- ③：1回合1次，场上的其他怪兽的表示形式变更的场合，以场上1张卡为对象才能发动。那张卡回到手卡。
local s,id,o=GetID()
-- 注册“转轮之斯芬克斯”的①②③三个效果：①在手卡/墓地可因怪兽表示形式变更以除外墓地1张魔法卡为代价特殊召唤；②在自己主要阶段从卡组·墓地各最多1张盖放太阳之书/月之书；③在场上其他怪兽表示形式变更时取场上1张卡回手。
function s.initial_effect(c)
	-- 将「太阳之书」(38699854)和「月之书」(14087893)的卡号注册进这张卡的代码列表，用于检索/判定这张卡记载的卡名。
	aux.AddCodeList(c,38699854,14087893)
	-- 这个卡名的①②的效果1回合各能使用1次。①：怪兽的表示形式变更的场合，从自己墓地把1张魔法卡除外才能发动。这张卡从手卡·墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_CHANGE_POS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：自己主要阶段才能发动。从自己的卡组·墓地把「太阳之书」和「月之书」各最多1张在自己的魔法与陷阱区域盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"盖放"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	-- ③：1回合1次，场上的其他怪兽的表示形式变更的场合，以场上1张卡为对象才能发动。那张卡回到手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"回到手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CHANGE_POS)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 代价过滤函数：用于选择可作为发动代价的卡，要求是魔法卡且能够被除外。
function s.costfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
-- ①效果的代价函数：检查墓地是否存在可除外的魔法卡；存在则选择1张除外，否则不能发动。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测时，确认自己墓地存在至少1张满足costfilter的魔法卡（排除效果持有者自身）作为可支付的代价。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 向当前玩家显示“请选择要除外的卡”的消息提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让当前玩家从自己墓地选择1张满足costfilter的魔法卡作为发动代价。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 将作为代价选择的卡以表侧表示除外，完成代价支付。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ①效果的发动目标检查：确认自己场上有空余的怪兽区域，且这张卡本身可以被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否还有可用的主要怪兽区域空位，用于特殊召唤这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，声明本效果将要把这张卡特殊召唤，供后续规则检测（如星尘龙等）使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与当前连锁相关且不受王家长眠之谷影响，则将其从手卡·墓地特殊召唤到自己的主要怪兽区。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡没有因为离场等原因与连锁失去联系，并且不处于“王家长眠之谷”的无效影响下，才能继续特殊召唤。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将这张卡以表侧攻击表示特殊召唤到当前玩家的场上，无视召唤条件和苏生限制。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 对象过滤函数：判定卡是「太阳之书」或「月之书」，且可以在魔法与陷阱区域盖放。
function s.setfilter(c)
	return c:IsCode(38699854,14087893) and c:IsSSetable()
end
-- ②效果的发动条件：确认自己卡组·墓地存在至少1张可以盖放的「太阳之书」或「月之书」。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测时，检查卡组·墓地中是否存在满足setfilter的可盖放「太阳之书」或「月之书」。
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
-- ②效果处理：计算可用魔陷区数量，从卡组·墓地选择1–2张卡名不同的「太阳之书」/「月之书」（各最多1张）盖放到魔陷区。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己魔法与陷阱区域当前可用的空格数量，用于决定最多能盖放几张。
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft<=0 then return end
	if ft>=2 then ft=2 end
	-- 获取卡组·墓地中全部不受王家长眠之谷影响且满足setfilter的「太阳之书」/「月之书」作为候选组。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	if g:GetCount()>0 then
		-- 向当前玩家显示“请选择要盖放的卡”的消息提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 让玩家从候选卡中选择1到ft张，且所选卡名互不相同（保证太阳之书和月之书各最多1张），用于盖放。
		local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ft)
		if sg:GetCount()>0 then
			-- 将选择的「太阳之书」/「月之书」以里侧表示盖放到自己的魔法与陷阱区域。
			Duel.SSet(tp,sg)
		end
	end
end
-- ③效果的触发条件：检测到表示形式变更的怪兽组中包含除这张卡以外的其他怪兽。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认发生表示形式变更的怪兽中，除去这张卡自身后至少还存在1只其他怪兽，才满足③的发动条件。
	return eg:FilterCount(aux.TRUE,e:GetHandler())>0
end
-- ③效果的发动与选目标：选择场上1张可以返回手卡的卡作为对象，并设置返回手牌的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToHand() end
	-- 发动检测时，确认场上存在至少1张能够作为对象且可以返回手卡的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向当前玩家显示“请选择要返回手牌的卡”的消息提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 从双方场上选择1张可返回手卡的卡作为效果对象，并记录为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息，声明本效果将使选择的卡返回手卡，供连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ③效果处理：取得对象卡，若仍与当前连锁相关，则将其返回手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得③效果选择的对象卡（场上被选中的那张卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 将对象卡送回其持有者的手卡，返回原因是效果处理。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
