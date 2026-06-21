--影王デュークシェード
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次，这张卡的效果发动的回合，自己不是暗属性怪兽不能特殊召唤。
-- ①：把自己场上的暗属性怪兽任意数量解放才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡的攻击力上升解放的怪兽数量×500。
-- ②：这张卡召唤·特殊召唤成功的场合，以自己墓地1只5星以上的暗属性怪兽为对象才能发动。那只怪兽加入手卡。
function c12766474.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次，这张卡的效果发动的回合，自己不是暗属性怪兽不能特殊召唤。①：把自己场上的暗属性怪兽任意数量解放才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡的攻击力上升解放的怪兽数量×500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12766474,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,12766474)
	e1:SetCost(c12766474.spcost)
	e1:SetTarget(c12766474.sptg)
	e1:SetOperation(c12766474.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次，这张卡的效果发动的回合，自己不是暗属性怪兽不能特殊召唤。②：这张卡召唤·特殊召唤成功的场合，以自己墓地1只5星以上的暗属性怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12766474,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,12766475)
	e2:SetCost(c12766474.thcost)
	e2:SetTarget(c12766474.thtg)
	e2:SetOperation(c12766474.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- 注册自定义活动计数器，用于监测本回合是否特殊召唤过非暗属性的怪兽
	Duel.AddCustomActivityCounter(12766474,ACTIVITY_SPSUMMON,c12766474.counterfilter)
end
-- 过滤函数，检查特殊召唤 of 怪兽是否为表侧表示的暗属性怪兽
function c12766474.counterfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsFaceup()
end
-- 过滤函数，检查指定卡片是否包含在卡片组中
function c12766474.relfilter(c,g)
	return g:IsContains(c)
end
-- 效果①的发动代价：判断本回合是否未特殊召唤过非暗属性怪兽，并确认场上存在可供解放且解放后能留出空位的暗属性怪兽
function c12766474.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上可以被解放的暗属性怪兽卡片组
	local rg=Duel.GetReleaseGroup(tp):Filter(Card.IsAttribute,nil,ATTRIBUTE_DARK)
	-- 在chk==0时，检查自己本回合是否没有特殊召唤过非暗属性的怪兽
	if chk==0 then return Duel.GetCustomActivityCount(12766474,tp,ACTIVITY_SPSUMMON)==0
		-- 检查是否可以解放任意数量的暗属性怪兽并留出空闲的怪兽区域用于特殊召唤
		and rg:CheckSubGroup(aux.mzctcheckrel,1,#rg,tp) end
	-- 这个卡名的①②的效果1回合各能使用1次，这张卡的效果发动的回合，自己不是暗属性怪兽不能特殊召唤。①：把自己场上的暗属性怪兽任意数量解放才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡的攻击力上升解放的怪兽数量×500。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c12766474.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为玩家注册本回合不能特殊召唤非暗属性怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
	-- 设置提示信息为选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 从可解放怪兽中选择解放后可留出特殊召唤位置的怪兽组合
	local g=rg:SelectSubGroup(tp,aux.mzctcheckrel,false,1,#rg,tp)
	e:SetLabel(g:GetCount())
	-- 若存在代替解放的效果则应用之（如暗影敌托邦）
	aux.UseExtraReleaseCount(g,tp)
	-- 解放所选怪兽以支付发动的代价
	Duel.Release(g,REASON_COST)
end
-- 限制特殊召唤的怪兽只能是暗属性怪兽
function c12766474.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsAttribute(ATTRIBUTE_DARK)
end
-- 效果①的发动准备：判断手牌的这张卡是否可以特殊召唤，并设置特殊召唤的操作信息
function c12766474.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，包含卡片自身与特殊召唤的数量（1张）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理：尝试将自身特殊召唤，若成功则根据解放的怪兽数量增加攻击力，并完成特殊召唤
function c12766474.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍与效果相关，并尝试以表侧表示进行特殊召唤的第一步操作
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		local ct=e:GetLabel()
		-- 这个效果特殊召唤的这张卡的攻击力上升解放的怪兽数量×500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
	-- 完成特殊召唤的处理流程
	Duel.SpecialSummonComplete()
end
-- 效果②的发动代价：判断本回合是否未特殊召唤过非暗属性怪兽，并注册本回合不能特殊召唤非暗属性怪兽的限制效果
function c12766474.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk==0时，检查自己本回合是否没有特殊召唤过非暗属性的怪兽
	if chk==0 then return Duel.GetCustomActivityCount(12766474,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个卡名的①②的效果1回合各能使用1次，这张卡的效果发动的回合，自己不是暗属性怪兽不能特殊召唤。②：这张卡召唤·特殊召唤成功的场合，以自己墓地1只5星以上的暗属性怪兽为对象才能发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c12766474.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为玩家注册本回合不能特殊召唤非暗属性怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 墓地卡片的过滤条件：等级5星以上、暗属性且可以加入手牌的怪兽
function c12766474.thfilter(c)
	return c:IsLevelAbove(5) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToHand()
end
-- 效果②的发动准备：判断墓地是否存在符合条件的卡片，并选择其中1只作为效果的对象，设置加入手牌的操作信息
function c12766474.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c12766474.thfilter(chkc) end
	-- 在chk==0时，判断自己墓地是否存在可以加入手牌的5星以上暗属性怪兽
	if chk==0 then return Duel.IsExistingTarget(c12766474.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置提示信息为选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地中1只符合条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c12766474.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置将所选卡片加入手牌的操作信息，操作数量为1
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的效果处理：获取被选择的对象怪兽，将其加入手牌并展示
function c12766474.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果所指定的第一个对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽加入持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end
