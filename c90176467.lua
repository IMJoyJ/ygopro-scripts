--夢魔鏡の逆徒－ネイロイ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1只「梦魔镜的使徒-涅洛伊」加入手卡。那之后，可以把这张卡变成光属性。
-- ②：把自己场上1只其他的「梦魔镜」怪兽解放才能发动。从卡组选1只和那只是等级不同的「梦魔镜」怪兽，把1张在选的怪兽有卡名记述的「圣光之梦魔镜」或者「黯黑之梦魔镜」从卡组加入手卡，选的怪兽守备表示特殊召唤。
function c90176467.initial_effect(c)
	-- 注册卡片效果中记述的卡片密码（圣光之梦魔镜、黯黑之梦魔镜、梦魔镜的使徒-涅洛伊）
	aux.AddCodeList(c,74665651,1050355,18189187)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1只「梦魔镜的使徒-涅洛伊」加入手卡。那之后，可以把这张卡变成光属性。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(90176467,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,90176467)
	e1:SetTarget(c90176467.thtg)
	e1:SetOperation(c90176467.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：把自己场上1只其他的「梦魔镜」怪兽解放才能发动。从卡组选1只和那只是等级不同的「梦魔镜」怪兽，把1张在选的怪兽有卡名记述的「圣光之梦魔镜」或者「黯黑之梦魔镜」从卡组加入手卡，选的怪兽守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(90176467,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,90176468)
	e3:SetCost(c90176467.spcost)
	e3:SetTarget(c90176467.sptg)
	e3:SetOperation(c90176467.spop)
	c:RegisterEffect(e3)
end
-- 过滤卡组中「梦魔镜的使徒-涅洛伊」且能加入手牌的卡
function c90176467.thfilter(c)
	return c:IsCode(18189187) and c:IsAbleToHand()
end
-- 效果①（检索「梦魔镜的使徒-涅洛伊」）的发动准备与合法性检查
function c90176467.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可检索的「梦魔镜的使徒-涅洛伊」
	if chk==0 then return Duel.IsExistingMatchingCard(c90176467.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息，表示该效果包含从卡组将1张卡加入手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①（检索「梦魔镜的使徒-涅洛伊」并可选变更为光属性）的处理函数
function c90176467.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只「梦魔镜的使徒-涅洛伊」
	local g=Duel.SelectMatchingCard(tp,c90176467.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 若成功将选中的卡加入手牌
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) and c:IsFaceup() and not c:IsAttribute(ATTRIBUTE_LIGHT)
			-- 询问玩家是否选择将这张卡变成光属性
			and Duel.SelectYesNo(tp,aux.Stringid(90176467,2)) then  --"是否变成光属性？"
			-- 中断当前效果处理，使后续的属性变更处理不与检索同时进行
			Duel.BreakEffect()
			-- 可以把这张卡变成光属性。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			e1:SetValue(ATTRIBUTE_LIGHT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
		end
	end
end
-- 过滤场上可作为解放Cost的「梦魔镜」怪兽（需满足：表侧表示、有等级、解放后能腾出怪兽区域、且卡组有可特召的等级不同的「梦魔镜」怪兽）
function c90176467.costfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x131) and c:IsLevelAbove(0)
		-- 检查卡组中是否存在与该怪兽等级不同且满足特召及检索条件的「梦魔镜」怪兽
		and Duel.IsExistingMatchingCard(c90176467.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetLevel())
		-- 检查将该怪兽解放后，是否能腾出可用于特殊召唤的怪兽区域
		and Duel.GetMZoneCount(tp,c)>0
end
-- 过滤卡组中可特殊召唤的「梦魔镜」怪兽（需满足：等级与被解放怪兽不同、可守备表示特召、且卡组中存在其记述的「圣光之梦魔镜」或「黯黑之梦魔镜」）
function c90176467.spfilter(c,e,tp,lv)
	return c:IsSetCard(0x131) and not c:IsLevel(lv)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 检查该怪兽是否记述了「圣光之梦魔镜」且卡组中存在「圣光之梦魔镜」
		and (aux.IsCodeListed(c,74665651) and Duel.IsExistingMatchingCard(c90176467.spthfilter,tp,LOCATION_DECK,0,1,nil,74665651)
			-- 或者该怪兽是否记述了「黯黑之梦魔镜」且卡组中存在「黯黑之梦魔镜」
			or aux.IsCodeListed(c,1050355) and Duel.IsExistingMatchingCard(c90176467.spthfilter,tp,LOCATION_DECK,0,1,nil,1050355))
end
-- 过滤卡组中特定卡名（圣光之梦魔镜或黯黑之梦魔镜）且能加入手牌的卡
function c90176467.spthfilter(c,code)
	return c:IsCode(code) and c:IsAbleToHand()
end
-- 效果②的发动Cost处理函数（解放自己场上1只其他的「梦魔镜」怪兽，并记录其等级）
function c90176467.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		-- 检查场上是否存在除自身以外可解放的、满足条件的「梦魔镜」怪兽
		if Duel.CheckReleaseGroup(tp,c90176467.costfilter,1,c,e,tp) then
			e:SetLabel(1)
			return true
		else
			e:SetLabel(0)
			return false
		end
	end
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 玩家选择1只满足条件的「梦魔镜」怪兽
	local rc=Duel.SelectReleaseGroup(tp,c90176467.costfilter,1,1,c,e,tp):GetFirst()
	e:SetLabel(rc:GetLevel())
	-- 将选中的怪兽解放
	Duel.Release(rc,REASON_COST)
end
-- 效果②的发动准备与合法性检查
function c90176467.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetLabel()>0 end
	-- 设置连锁信息，表示该效果包含从卡组将1张卡加入手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置连锁信息，表示该效果包含从卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
-- 效果②（检索记述的场地并特召选中的梦魔镜怪兽）的处理函数
function c90176467.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否有空位，若无则无法处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只与被解放怪兽等级不同且满足特召及检索条件的「梦魔镜」怪兽
	local g=Duel.SelectMatchingCard(tp,c90176467.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,e:GetLabel())
	if #g>0 then
		local tc=g:GetFirst()
		local g2=Group.CreateGroup()
		-- 检查选中的怪兽是否记述了「圣光之梦魔镜」
		if aux.IsCodeListed(tc,74665651) then
			-- 将卡组中的「圣光之梦魔镜」合并到待检索的卡片组中
			g2:Merge(Duel.GetMatchingGroup(c90176467.spthfilter,tp,LOCATION_DECK,0,nil,74665651))
		end
		-- 检查选中的怪兽是否记述了「黯黑之梦魔镜」
		if aux.IsCodeListed(tc,1050355) then
			-- 将卡组中的「黯黑之梦魔镜」合并到待检索的卡片组中
			g2:Merge(Duel.GetMatchingGroup(c90176467.spthfilter,tp,LOCATION_DECK,0,nil,1050355))
		end
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local thg=g2:Select(tp,1,1,nil)
		-- 将选中的场地魔法卡加入手牌
		Duel.SendtoHand(thg,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,thg)
		-- 将选中的「梦魔镜」怪兽以表侧守备表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
