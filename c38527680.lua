--ユニオン・アクティベーション
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：机械族·光属性的1只通常怪兽或同盟怪兽从手卡·卡组送去墓地，和那只怪兽是攻击力相同而原本卡名不同的1只机械族·光属性怪兽从卡组加入手卡。
-- ②：这张卡在墓地存在的状态，自己把机械族·光属性怪兽3只同时特殊召唤的场合，把这张卡除外才能发动。从卡组把1只攻击力3000以上的怪兽加入手卡。那之后，进行那1只怪兽的召唤。
local s,id,o=GetID()
-- 为「同盟激活」注册两个效果：e1为①的魔法卡发动效果（从手卡·卡组送墓1只机械族·光属性通常/同盟怪兽并检索1只攻击力相同、原本卡名不同的机械族·光属性怪兽）；e2为②的墓地触发效果（自己同时特殊召唤3只机械族·光属性怪兽时，除外自身，检索并召唤1只攻击力3000以上的怪兽）；两个效果分别受同名卡1回合1次限制。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：机械族·光属性的1只通常怪兽或同盟怪兽从手卡·卡组送去墓地，和那只怪兽是攻击力相同而原本卡名不同的1只机械族·光属性怪兽从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己把机械族·光属性怪兽3只同时特殊召唤的场合，把这张卡除外才能发动。从卡组把1只攻击力3000以上的怪兽加入手卡。那之后，进行那1只怪兽的召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"加入手卡并召唤"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	-- 设置②的发动代价：把墓地中的这张卡除外（aux.bfgcost会检查可除外并执行除外作为COST）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.has_text_type=TYPE_UNION
-- ①的送墓对象筛选：该怪兽必须机械族·光属性，且是通常怪兽或同盟怪兽，能够被送去墓地；并且卡组中还存在1只与它攻击力相同、原本卡名不同的机械族·光属性怪兽可检索，保证①能完成检索。
function s.tgfilter(c,tp)
	return c:IsType(TYPE_NORMAL+TYPE_UNION) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE) and c:IsAbleToGrave()
		-- 在送墓候选的判断中额外检查：卡组里存在1只不包含送墓候选c本身、原本卡名与c不同、攻击力与c相同、机械族·光属性且能加入手卡的怪兽。
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,c,c:GetOriginalCodeRule(),c:GetAttack())
end
-- ①的检索目标筛选：卡组中的怪兽不是送墓怪兽的原本卡号（原本卡名不同），属性为光、种族为机械，攻击力与送墓怪兽相同，且能加入手卡。
function s.thfilter(c,code,atk)
	return not c:IsOriginalCodeRule(code) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE) and c:IsAttack(atk) and c:IsAbleToHand()
end
-- ①的发动条件与操作信息登记：发动时判断是否存在符合条件的送墓对象和检索对象；然后登记本次效果会进行1张卡送去墓地、1张卡加入手卡。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0时检查合法发动：自己手卡·卡组中存在满足s.tgfilter的怪兽（即送墓后能触发检索的机械族·光属性通常/同盟怪兽）。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,tp) end
	-- 登记本次连锁将有1张卡送去墓地（SetOperationInfo按卡组位置登记；实际可由手卡·卡组选择），供其他卡进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 登记本次连锁将有1张卡从卡组加入手卡，供其他卡进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①的处理：先选择1只机械族·光属性通常/同盟怪兽从手卡·卡组送去墓地；送墓成功且该卡在墓地时，再选择1只攻击力相同、原本卡名不同的机械族·光属性怪兽加入手卡，并向对方展示。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，让玩家从手卡·卡组选择1张要送去墓地的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己的手卡·卡组选择1张满足s.tgfilter的机械族·光属性通常/同盟怪兽作为送墓对象。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tp)
	local tc=g:GetFirst()
	-- 将所选怪兽以效果原因送去墓地；若实际送入墓地成功且该卡仍位于墓地（例如没有被除外或回卡组代替），则继续执行检索。
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) then
		-- 显示选择提示，让玩家选择1张要加入手卡的检索目标。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1张满足s.thfilter的怪兽：与已送墓怪兽原本卡名不同、攻击力相同，且是光属性机械族、能加入手卡。
		local sg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tc:GetOriginalCodeRule(),tc:GetAttack())
		if sg:GetCount()>0 then
			-- 将检索到的怪兽加入其持有者的手卡（nil表示加入持有者手卡）。
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 向对方玩家展示检索加入手卡的怪兽，确认检索结果。
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
-- ②触发条件的单卡判定：该怪兽是这次特殊召唤中由己方玩家特殊召唤、表侧表示、光属性·机械族。
function s.spfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE) and c:IsFaceup()
end
-- ②的触发条件：本次同时特殊召唤成功的一组怪兽中，有3只以上是己方特殊召唤的光属性·机械族表侧表示怪兽。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spfilter,3,nil,tp)
end
-- ②的检索目标条件：卡组中攻击力3000以上、能够通常召唤、能够加入手卡，同时通过s.sunthfilter确认召唤手续可行，并且己方可以对该怪兽进行上级召唤。
function s.thfilter2(c,e,tp)
	local minc,maxc=c:GetTributeRequirement()
	-- 最终判定条件：攻击力在3000以上；该卡自身能被通常召唤且当前满足通常召唤条件；可以加入手卡；能通过召唤手续检查（包括祭品限制、召唤手续、祭品数量等）；且己方当前可以进行该上级召唤。
	return c:IsAttackAbove(3000) and c:IsSummonable(true,nil) and c:IsSummonableCard() and c:IsAbleToHand() and s.sunthfilter(c,e,tp,minc,maxc) and Duel.IsPlayerCanSummon(tp,SUMMON_TYPE_ADVANCE,c)
end
-- 为②选出的怪兽做召唤可行性检查：若存在可适用的『随风旅鸟与未知之风』且该怪兽符合2只解放条件，则临时赋予其用自己场上1只怪兽+对方场上1张卡代替解放的召唤手续；再依次检查祭品限制、召唤手续、祭品数量、禁止召唤限制，全部通过才可召唤。
function s.sunthfilter(c,e,tp,minc,maxc)
	local e1=nil
	-- 若目标怪兽的召唤需要2只解放，且自己魔法与陷阱区域存在效果未被无效的『随风旅鸟与未知之风』，则临时给该怪兽注册一个自定义上级召唤手续，用于支持以后者方式代替解放。
	if s.ottg(e,c) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_SZONE,0,1,nil) then
		-- 对应『随风旅鸟与未知之风』的①：『只要这张卡在魔法与陷阱区域存在，自己作需要怪兽2只解放的上级召唤的场合，可以不把怪兽2只解放而把自己场上1只怪兽和对方场上1张卡送去墓地来上级召唤。』；并对应『同盟激活』②的后半句：『从卡组把1只攻击力3000以上的怪兽加入手卡。那之后，进行那1只怪兽的召唤。』
		e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SUMMON_PROC)
		e1:SetCondition(s.otcon)
		e1:SetValue(SUMMON_TYPE_ADVANCE)
		c:RegisterEffect(e1,true)
	end
	if c:IsHasEffect(EFFECT_TRIBUTE_LIMIT,c:GetControler()) then
		local te=c:IsHasEffect(EFFECT_TRIBUTE_LIMIT,tp)
		local ev=te:GetValue()
		-- 如果目标怪兽具有祭品限制效果，则要确认自己场上存在至少1只满足该祭品限制条件的怪兽；否则不能进行这次召唤。
		if not Duel.IsExistingMatchingCard(s.sunthfilter2,tp,LOCATION_MZONE,0,1,nil,e,ev) then
			return false
		end
	end
	if c:IsHasEffect(EFFECT_LIMIT_SUMMON_PROC,c:GetControler()) then
		local tte=c:IsHasEffect(EFFECT_LIMIT_SUMMON_PROC,c:GetControler())
		local ec=tte:GetCondition()
		if not ec(e,c,0) then return false end
	end
	if c:IsHasEffect(EFFECT_SUMMON_PROC,c:GetControler()) then
		local tte=c:IsHasEffect(EFFECT_SUMMON_PROC,c:GetControler())
		local ec=tte:GetCondition()
		if ec(e,c,0) then
			return true
		end
	else
		-- 对于没有特殊召唤手续、按通常的上级召唤处理的情况，检查场上满足祭品数量（min~max）；祭品不足则不能召唤。
		if not Duel.CheckTribute(c,minc,maxc) then return false end
	end
	if c:IsHasEffect(EFFECT_CANNOT_SUMMON,c:GetControler()) then
		return false
	end
	if e1 then e1:Reset() end
	return true
end
-- 判断场上是否存在卡号55521751『随风旅鸟与未知之风』，且该卡效果没有被无效。
function s.cfilter(c)
	return c:IsCode(55521751) and not c:IsDisabled()
end
-- 用于『随风旅鸟与未知之风』代替解放的自己场上怪兽筛选：该怪兽可送去墓地、不免疫当前效果，并且把它解放后仍有空余怪兽区用来上级召唤。
function s.otfilter(c,e,tp)
	-- 该自己怪兽必须满足：能被效果送去墓地、不免疫此效果，且解放后自己场上仍有可用怪兽区。
	return c:IsAbleToGrave() and not c:IsImmuneToEffect(e) and Duel.GetMZoneCount(tp,c)>0
end
-- 用于『随风旅鸟与未知之风』代替解放的对方场上卡的筛选：可送去墓地、不免疫当前效果，并且未被标记为已确定离场。
function s.otfilter2(c,e)
	return c:IsAbleToGrave() and not c:IsImmuneToEffect(e) and not c:IsStatus(STATUS_LEAVE_CONFIRMED)
end
-- 自定义召唤手续的触发条件：目标怪兽所需祭品数不超过2；自己场上存在1只可送去墓地的怪兽，且对方场上存在1张可送去墓地的卡；从而满足『随风旅鸟与未知之风』用1只自己怪兽+对方1张卡代替2只解放的条件。
function s.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	return minc<=2
		-- 检查自己场上是否存在1只可送去墓地且不免疫当前效果的怪兽，用于代替自己的2只解放。
		and Duel.IsExistingMatchingCard(s.otfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
		-- 检查对方场上是否存在1张可送去墓地且不免疫当前效果的卡，用于代替对方的解放（实际是作为额外送入墓地的卡）。
		and Duel.IsExistingMatchingCard(s.otfilter2,tp,0,LOCATION_ONFIELD,1,nil,e)
end
-- 判断目标怪兽的通常召唤解放要求：其所需祭品最小数不超过2、最大数至少为2，即属于『需要怪兽2只解放的上级召唤』。
function s.ottg(e,c)
	local mi,ma=c:GetTributeRequirement()
	return mi<=2 and ma>=2
end
-- 辅助判断函数：把EFFECT_TRIBUTE_LIMIT的value函数ev应用到祭品候选c上，判断c是否符合该祭品限制。
function s.sunthfilter2(c,e,ev)
	return ev(e,c)
end
-- ②的发动条件与操作信息：chk==0时检查卡组是否存在满足s.thfilter2的怪兽；存在则登记本次处理会将1张卡从卡组加入手卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0时检查：卡组中是否有1只攻击力3000以上、可召唤且可加入手卡的怪兽，以满足②的发动条件。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记本次连锁将有1张卡从卡组加入手卡，供连锁判定等场合使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②的处理：从卡组选择1只攻击力3000以上且可召唤的怪兽加入手卡，向对方确认；随后中断当前效果处理，并在无视通常召唤次数限制的情况下进行那只怪兽的召唤。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，让玩家选择1只要加入手卡并召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足s.thfilter2的怪兽作为检索并召唤的对象。
	local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 将所选怪兽加入手卡；若加入成功且该怪兽仍然可以通常召唤，则继续执行后续的召唤处理。
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsSummonable(true,nil) then
		-- 向对方玩家展示这张加入手卡的怪兽，以便确认检索结果。
		Duel.ConfirmCards(1-tp,tc)
		-- 调用BreakEffect中断当前效果，让接下来的召唤处理视为不同时点的处理（模拟原文‘那之后’的先后顺序）。
		Duel.BreakEffect()
		-- 让己方玩家对那只怪兽进行通常召唤：ignore_count=true表示不消耗本回合通常召唤次数，e=nil表示按通常规则判定召唤条件；此处实际进行的是上级召唤。
		Duel.Summon(tp,tc,true,nil)
	end
end
