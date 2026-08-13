--プランキッズ・ミュー
-- 效果：
-- 4星以下的「调皮宝贝」怪兽1只
-- 自己对「调皮宝贝喵喵猫」1回合只能有1次连接召唤，那个效果1回合只能使用1次。
-- ①：对方回合自己场上的「调皮宝贝」怪兽为让效果发动而把自身解放的场合，可以作为代替把场上·墓地的这张卡除外。
function c25725326.initial_effect(c)
	-- 为这张卡添加连接召唤手续：使用1只满足过滤条件（4星以下且视为「调皮宝贝」）的怪兽作为连接素材。
	aux.AddLinkProcedure(c,c25725326.mfilter,1,1)
	c:EnableReviveLimit()
	-- 自己对「调皮宝贝喵喵猫」1回合只能有1次连接召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c25725326.regcon)
	e1:SetOperation(c25725326.regop)
	c:RegisterEffect(e1)
	-- 那个效果1回合只能使用1次。①：对方回合自己场上的「调皮宝贝」怪兽为让效果发动而把自身解放的场合，可以作为代替把场上·墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(25725326)
	e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e2:SetCountLimit(1,25725326)
	e2:SetCondition(c25725326.repcon)
	c:RegisterEffect(e2)
end
-- 连接素材的过滤条件：等级4以下的怪兽，且作为连接素材时视为「调皮宝贝」系列。
function c25725326.mfilter(c)
	return c:IsLevelBelow(4) and c:IsLinkSetCard(0x120)
end
-- 触发条件的判断：这张卡以连接召唤方式特殊召唤成功时才触发。
function c25725326.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- e1效果处理：为控制者附加直到结束阶段为止的『不能连接召唤「调皮宝贝喵喵猫」』的限制，防止本回合重复进行同名卡的连接召唤。
function c25725326.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 自己对「调皮宝贝喵喵猫」1回合只能有1次连接召唤；①：对方回合自己场上的「调皮宝贝」怪兽为让效果发动而把自身解放的场合，可以作为代替把场上·墓地的这张卡除外。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(c25725326.splimit)
	-- 将上述限制效果 e1 注册给当前玩家，使其在本回合内受到对应特殊召唤限制。
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件的具体判断：只有怪兽是「调皮宝贝喵喵猫」且召唤方式为连接召唤时，该特殊召唤被禁止。
function c25725326.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(25725326) and bit.band(sumtype,SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end
-- e2效果的发动条件：当前回合玩家是这张卡控制者的对方，即仅在对方回合可以被使用。
function c25725326.repcon(e)
	-- 返回真值：若当前回合玩家不是这张卡的控制者（即对方回合），则满足条件。
	return Duel.GetTurnPlayer()==1-e:GetHandlerPlayer()
end
