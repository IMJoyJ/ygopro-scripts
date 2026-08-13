--儀式の下準備
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组选1张仪式魔法卡，再从自己的卡组·墓地选1只在那张仪式魔法卡有卡名记述的仪式怪兽。那2张卡加入手卡。
function c13048472.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从卡组选1张仪式魔法卡，再从自己的卡组·墓地选1只在那张仪式魔法卡有卡名记述的仪式怪兽。那2张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,13048472+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c13048472.target)
	e1:SetOperation(c13048472.activate)
	c:RegisterEffect(e1)
end
-- 筛选可作为检索对象的仪式魔法卡：该卡必须是仪式魔法卡且能加入手牌，并且卡组·墓地中存在至少1只满足后续条件（卡名被该仪式魔法卡记述、能加入手牌）的仪式怪兽。
function c13048472.filter(c,tp)
	return bit.band(c:GetType(),0x82)==0x82 and c:IsAbleToHand()
		-- 追加判定：存在至少1只与该仪式魔法卡对应、能从卡组·墓地加入手牌的仪式怪兽，确保检索两张卡的目标可以实现。
		and Duel.IsExistingMatchingCard(c13048472.filter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,c)
end
-- 筛选仪式怪兽候选：该怪兽必须是仪式怪兽且能加入手牌，并且其卡名被已选择的仪式魔法卡mc的文本所记述。
function c13048472.filter2(c,mc)
	-- 具体条件为：c是仪式怪兽、c能加入手牌、且mc的效果文本中记载了c的卡名。
	return bit.band(c:GetType(),0x81)==0x81 and c:IsAbleToHand() and aux.IsCodeListed(mc,c:GetCode())
end
-- 效果发动时的目标判定与操作信息注册：在发动时检查是否满足检索前提，并告知系统本效果将要把2张卡从卡组·墓地加入手牌。
function c13048472.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性判定时，检查卡组中是否存在符合filter条件的仪式魔法卡（即能检索出仪式魔法卡且存在对应仪式怪兽），以此作为能否发动的前提。
	if chk==0 then return Duel.IsExistingMatchingCard(c13048472.filter,tp,LOCATION_DECK,0,1,nil,tp) end
	-- 设置操作信息：该效果属于加入手牌/检索类效果，预计处理2张卡，来源为卡组·墓地，用于让系统正确识别效果类型并供其他卡牌效果互动。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理时的执行流程：先选择1张仪式魔法卡，再选择1只对应的仪式怪兽，将两者加入手牌，并向对方展示确认。
function c13048472.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示消息，告知当前玩家需要选择一张要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选出1张符合条件的仪式魔法卡（该筛选已保证存在对应的仪式怪兽）。
	local g=Duel.SelectMatchingCard(tp,c13048472.filter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if g:GetCount()>0 then
		-- 以选中的仪式魔法卡为基准，从卡组·墓地获取所有符合条件的仪式怪兽候选组，同时通过王家长眠之谷过滤，使墓地卡片在禁止特殊召唤等限制下不会被错误选中。
		local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c13048472.filter2),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,g:GetFirst())
		if mg:GetCount()>0 then
			-- 再次弹出选择提示消息，让玩家从候选仪式怪兽中选择1张要加入手牌的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=mg:Select(tp,1,1,nil)
			g:Merge(sg)
			-- 将选中的仪式魔法卡与仪式怪兽合并后，以效果处理的原因加入其持有者的手牌。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 将加入手牌的那些卡展示给对方玩家确认，以符合检索/回手牌效果的公开确认规则。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
