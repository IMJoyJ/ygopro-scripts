--大屍教
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从手卡·卡组把1只恶魔族·不死族的仪式怪兽送去墓地。那之后，可以从卡组把1张仪式魔法卡加入手卡。
-- ②：这张卡被除外的场合，以自己的除外状态的1只4星以下的恶魔族·不死族怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 创建并注册该卡的全部效果：①为召唤/特殊召唤成功时的诱发效果（e1/e2），②为除外时的诱发效果（e3），分别设置发动时机、类型、限制及处理函数。
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从手卡·卡组把1只恶魔族·不死族的仪式怪兽送去墓地。那之后，可以从卡组把1张仪式魔法卡加入手卡。（此处为召唤成功时效果e1，特殊召唤成功时由e2克隆实现）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡被除外的场合，以自己的除外状态的1只4星以下的恶魔族·不死族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_REMOVE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 该筛选函数用于从手卡·卡组中找出恶魔族或不死族、且为仪式怪兽类型、并且能被送去墓地的卡，作为①送入墓地的候选。
function s.tgfilter(c)
	return c:IsRace(RACE_ZOMBIE+RACE_FIEND) and c:IsAllTypes(TYPE_RITUAL+TYPE_MONSTER) and c:IsAbleToGrave()
end
-- ①的发动条件与目标设定函数：在发动时确认存在满足条件的仪式怪兽，并设置将1张卡送去墓地的操作信息（用于连锁时点检测）。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：判定手卡·卡组是否存在至少1张满足tgfilter的卡，若不存在则无法发动①。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil) end
	-- 将本次效果的“送去墓地”操作信息写入连锁，指定数量1、位置为卡组/手牌（此处标记为卡组）及对象持有者，供相关卡牌响应。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 该筛选函数用于从卡组中找出仪式魔法卡且能够加入手卡的卡，作为①后续检索仪式魔法的候选。
function s.thfilter(c)
	return c:IsAllTypes(TYPE_RITUAL+TYPE_SPELL) and c:IsAbleToHand()
end
-- ①的实际处理：从手卡·卡组选择1只仪式怪兽送入墓地；若送入成功且该卡在墓地，则选择是否从卡组将1张仪式魔法卡加入手卡，并向对方展示。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，让玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己的手卡·卡组中筛选并选择1张满足tgfilter的仪式怪兽卡（即要送去墓地的对象）。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因送去墓地，并确认确实有卡进入墓地，以决定是否继续执行检索仪式魔法卡的处理。
		if Duel.SendtoGrave(g,REASON_EFFECT)>0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) then
			-- 从自己卡组中检索所有满足thfilter（仪式魔法卡且可加入手卡）的卡，作为可选的加入手卡候选集合。
			local sg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
			-- 如果存在可加入手卡的仪式魔法卡，并且玩家在确认对话框中选择“是”，才执行后续加入手卡的处理。
			if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否加入手卡？"
				-- 将当前效果处理断开，使后续的“加入手卡”处理视为一个独立的效果处理节点，避免产生错误时点（错时点）。
				Duel.BreakEffect()
				-- 弹出选择提示，让玩家选择要加入手卡的仪式魔法卡。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
				local tg=sg:Select(tp,1,1,nil)
				-- 将玩家选择的仪式魔法卡加入其持有者的手卡（nil表示返回持有者手卡）。
				Duel.SendtoHand(tg,nil,REASON_EFFECT)
				-- 将刚才加入手卡的仪式魔法卡展示给对方玩家确认（公开检索信息）。
				Duel.ConfirmCards(1-tp,tg)
			end
		end
	end
end
-- 该筛选函数用于从除外区中找出表侧表示、恶魔族或不死族、等级4以下且能够被特殊召唤的怪兽，作为②的取对象候选。
function s.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_FIEND+RACE_ZOMBIE) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②的发动条件与取对象设定函数：需要自己场上怪兽区有空位，且除外区存在符合条件的对象；同时根据chkc校验对象合法性，并设置特殊召唤操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 发动②的条件之一：确认自己场上怪兽区存在至少1个可用的空格，用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动②的条件之二：确认除外区存在至少1只满足spfilter的怪兽，可作为对象被选择。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 弹出选择提示，让玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己除外区选择1只满足spfilter的怪兽作为②的效果对象，并自动与当前连锁建立对象联系。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 将本次效果的“特殊召唤”操作信息写入连锁，指定对象为已选择的怪兽，数量1，供连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②的实际处理：取得连锁对象卡，若该卡仍与效果相关联，则将其以表侧攻击表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理中登记的②效果对象卡（即除外区选择的那只怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧攻击表示特殊召唤到自己场上（不无视召唤条件和苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
