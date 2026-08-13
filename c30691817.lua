--海晶乙女シーエンジェル
-- 效果：
-- 4星以下的「海晶少女」怪兽1只
-- 自己对「海晶少女 海天使」1回合只能有1次连接召唤。
-- ①：这张卡连接召唤成功的场合才能发动。从卡组把1张「海晶少女」魔法卡加入手卡。
function c30691817.initial_effect(c)
	-- 为这张卡添加连接召唤手续，素材为1只等级4以下且作为连接素材时视为「海晶少女」的怪兽。
	aux.AddLinkProcedure(c,c30691817.mfilter,1,1)
	c:EnableReviveLimit()
	-- 自己对「海晶少女 海天使」1回合只能有1次连接召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c30691817.condition)
	e1:SetOperation(c30691817.regop)
	c:RegisterEffect(e1)
	-- ①：这张卡连接召唤成功的场合才能发动。从卡组把1张「海晶少女」魔法卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30691817,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,30691817)
	e2:SetCondition(c30691817.condition)
	e2:SetTarget(c30691817.thtg)
	e2:SetOperation(c30691817.thop)
	c:RegisterEffect(e2)
end
-- 连接素材过滤函数：筛选等级4以下、并且作为连接素材时视为「海晶少女」的怪兽。
function c30691817.mfilter(c)
	return c:IsLevelBelow(4) and c:IsLinkSetCard(0x12b)
end
-- 判断这张卡是否以连接召唤（SUMMON_TYPE_LINK）的方式特殊召唤成功。
function c30691817.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 在这张卡连接召唤成功时，为控制者注册一个直到结束阶段有效的自肃效果，限制本回合不能再进行「海晶少女 海天使」的连接召唤。
function c30691817.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 自己对「海晶少女 海天使」1回合只能有1次连接召唤。①：这张卡连接召唤成功的场合才能发动。从卡组把1张「海晶少女」魔法卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(c30691817.splimit)
	-- 将生成的场地效果注册给当前玩家tp，使其实际生效。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃限制的判定函数：仅当特殊召唤的怪兽是「海晶少女 海天使」（卡号30691817）且召唤方式为连接召唤时，该特殊召唤被禁止。
function c30691817.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(30691817) and bit.band(sumtype,SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end
-- 检索过滤函数：从卡组中筛选1张卡名含有「海晶少女」的魔法卡，且该卡能够加入手牌。
function c30691817.thfilter(c)
	return c:IsSetCard(0x12b) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 效果发动目标的处理函数：在发动时检查卡组是否存在符合条件的「海晶少女」魔法卡，若存在则设置操作信息，表明本效果将把1张卡从卡组加入手牌。
function c30691817.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：若卡组中不存在至少1张符合条件的「海晶少女」魔法卡，则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c30691817.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：声明本效果会将1张卡从卡组加入手牌，供系统进行发动检测与连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：玩家从卡组选择1张符合条件的「海晶少女」魔法卡加入手牌，并让对方确认检索的卡片。
function c30691817.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家tp显示选择提示消息，提示内容为“请选择要加入手牌的卡”，用于选择卡片的UI提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家tp从自己的卡组中选择1张满足thfilter条件的「海晶少女」魔法卡。
	local g=Duel.SelectMatchingCard(tp,c30691817.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手卡（nil表示返回持有者），原因记为效果处理。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将检索加入手牌的卡展示给对方玩家确认，确保信息公开。
		Duel.ConfirmCards(1-tp,g)
	end
end
