--天底の使徒
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从额外卡组把1只怪兽送去墓地。那之后，把持有送去墓地的怪兽的攻击力以下的攻击力的1只「教导」怪兽或「阿不思的落胤」从自己的卡组·墓地加入手卡。这张卡的发动后，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。
function c1984618.initial_effect(c)
	-- 将「阿不思的落胤」（68468459）登记为这张卡的关联卡名，用于处理与记载有该卡名相关的规则判定。
	aux.AddCodeList(c,68468459)
	-- 这个卡名的卡在1回合只能发动1张。①：从额外卡组把1只怪兽送去墓地。那之后，把持有送去墓地的怪兽的攻击力以下的攻击力的1只「教导」怪兽或「阿不思的落胤」从自己的卡组·墓地加入手卡。这张卡的发动后，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,1984618+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c1984618.target)
	e1:SetOperation(c1984618.activate)
	c:RegisterEffect(e1)
end
-- 定义用于发动检查的额外卡组怪兽过滤器：该怪兽必须能送去墓地，且当前卡组·墓地存在1只攻击力不高于它的「教导」怪兽或「阿不思的落胤」可供加入手卡。
function c1984618.tgfilter(c,tp)
	-- 返回true需同时满足：该额外怪兽可被送去墓地；且卡组·墓地存在符合条件的可加入手卡的「教导」怪兽或「阿不思的落胤」（攻击力≤该怪兽攻击力）。
	return c:IsAbleToGrave() and Duel.IsExistingMatchingCard(c1984618.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,c:GetAttack())
end
-- 定义效果处理时选择额外卡组怪兽的过滤器：与tgfilter类似，但对检索目标额外使用王家长眠之谷过滤，确保目标不受其影响。
function c1984618.opfilter(c,tp)
	-- 返回true需同时满足：该额外怪兽可被送去墓地；且卡组·墓地存在满足条件且不受王家长眠之谷影响的「教导」怪兽或「阿不思的落胤」。
	return c:IsAbleToGrave() and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c1984618.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,c:GetAttack())
end
-- 定义检索目标过滤器：目标卡是「教导」怪兽（0x145）或「阿不思的落胤」（68468459），攻击力不高于传入的atk，且能够加入手卡。
function c1984618.thfilter(c,atk)
	return (c:IsSetCard(0x145) and c:IsType(TYPE_MONSTER) or c:IsCode(68468459)) and c:IsAttackBelow(atk) and c:IsAbleToHand()
end
-- 效果发动时的目标处理：检查是否满足发动条件（存在可送去墓地的额外怪兽及可检索目标），并设置本次连锁的送去墓地与加入手卡的操作信息。
function c1984618.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查：额外卡组是否存在1只满足tgfilter的怪兽（可送墓且存在对应检索目标），作为能否发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c1984618.tgfilter,tp,LOCATION_EXTRA,0,1,nil,tp) end
	-- 设置操作信息：本次效果将有1张卡从额外卡组送去墓地（CATEGORY_TOGRAVE）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
	-- 设置操作信息：本次效果将有1张卡从卡组·墓地加入手卡（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理流程：先把选择1只额外卡组怪兽送去墓地，成功后再根据其攻击力从卡组·墓地选择1只符合条件的「教导」怪兽或「阿不思的落胤」加入手卡，并向对方展示；随后给自己附加直到回合结束不能从额外卡组特殊召唤的自肃效果。
function c1984618.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，提示操作玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从额外卡组选择1只满足opfilter的怪兽（该处opfilter会在处理时确保有可加入手卡的目标）作为送去墓地的对象。
	local g=Duel.SelectMatchingCard(tp,c1984618.opfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp)
	local tc=g:GetFirst()
	-- 判断选择的怪兽存在、送入墓地成功且仍位于墓地时，才继续执行检索加入手卡的流程；否则检索部分不处理。
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) then
		local atk=tc:GetAttack()
		-- 显示选择提示，提示操作玩家选择要加入手卡的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从自己的卡组·墓地选择1张满足thfilter且不受王家长眠之谷影响的「教导」怪兽或「阿不思的落胤」加入手卡，攻击力上限为刚送墓怪兽的攻击力。
		local hg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c1984618.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,atk)
		local hc=hg:GetFirst()
		if hc then
			-- 中断当前效果链，使此后的加入手卡处理与之前的送墓处理视为不同时处理，避免连续处理造成时点丢失。
			Duel.BreakEffect()
			-- 将选中的检索目标卡加入其持有者的手卡（nil表示按持有者），原因类型为效果。
			Duel.SendtoHand(hc,nil,REASON_EFFECT)
			-- 将加入手卡的卡展示给对方玩家确认，使检索结果透明化。
			Duel.ConfirmCards(1-tp,hc)
		end
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c1984618.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将自肃效果e1注册到当前操作玩家（tp），使其结束阶段前持续适用。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 自肃的判定条件：禁止特殊召唤的对象是位于额外卡组的怪兽，即不能从额外卡组进行怪兽的特殊召唤。
function c1984618.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
end
