--方界超帝インディオラ・デス・ボルト
-- 效果：
-- 这张卡不能通常召唤。把自己场上3只「方界」怪兽送去墓地的场合才能特殊召唤。
-- ①：这个方法特殊召唤的这张卡的攻击力上升2400。
-- ②：这张卡从手卡的特殊召唤成功的场合发动。给与对方800伤害。
-- ③：这张卡被对方送去墓地的场合，以自己墓地最多3只「方界」怪兽为对象才能发动。那些怪兽特殊召唤。那之后，可以从自己的卡组·墓地选1张「方界」卡加入手卡。
function c3775068.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把自己场上3只「方界」怪兽送去墓地的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c3775068.sprcon)
	e2:SetTarget(c3775068.sprtg)
	e2:SetOperation(c3775068.sprop)
	c:RegisterEffect(e2)
	-- ②：这张卡从手卡的特殊召唤成功的场合发动。给与对方800伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(3775068,0))  --"效果伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c3775068.damcon)
	e3:SetTarget(c3775068.damtg)
	e3:SetOperation(c3775068.damop)
	c:RegisterEffect(e3)
	-- ③：这张卡被对方送去墓地的场合，以自己墓地最多3只「方界」怪兽为对象才能发动。那些怪兽特殊召唤。那之后，可以从自己的卡组·墓地选1张「方界」卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(3775068,1))  --"特殊召唤墓地怪兽"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c3775068.spcon)
	e4:SetTarget(c3775068.sptg)
	e4:SetOperation(c3775068.spop)
	c:RegisterEffect(e4)
end
-- 过滤出表侧表示、持有「方界」字段并能作为代价送去墓地的怪兽。
function c3775068.spcfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe3) and c:IsAbleToGraveAsCost()
end
-- 特殊召唤条件判定：从自己场上选择3只符合条件的「方界」怪兽，并确认将它们作为代价送去墓地后仍留有空余的怪兽区域。
function c3775068.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己场上满足素材条件的「方界」怪兽组。
	local mg=Duel.GetMatchingGroup(c3775068.spcfilter,tp,LOCATION_MZONE,0,nil)
	-- 判定怪兽组中是否存在一组3张卡，能在作为素材送去墓地后确保场上仍有可用的怪兽区域。
	return mg:CheckSubGroup(aux.mzctcheck,3,3,tp)
end
-- 特殊召唤手续的选材阶段：从符合条件的怪兽组中选择3张作为代价素材，并将选中的组保存到效果标签中供处理阶段使用。
function c3775068.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上满足素材条件的「方界」怪兽组。
	local mg=Duel.GetMatchingGroup(c3775068.spcfilter,tp,LOCATION_MZONE,0,nil)
	-- 向玩家显示“请选择要送去墓地的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从素材候补组中自动选择满足格子检查的3张卡，若选择成功则返回该组；否则返回false。
	local sg=mg:SelectSubGroup(tp,aux.mzctcheck,true,3,3,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤手续的代价处理：将保存的3只「方界」怪兽作为代价送去墓地，并给特殊召唤成功的这张卡附加攻击力上升2400的永续效果。
function c3775068.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的3只「方界」怪兽以代价（REASON_COST）送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
	g:DeleteGroup()
	-- ①：这个方法特殊召唤的这张卡的攻击力上升2400。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(2400)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
end
-- 伤害效果的发动条件：这张卡从手卡特殊召唤成功。
function c3775068.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 伤害效果发动时：将对方设为伤害对象，伤害值设为800，并登记伤害效果的操作信息。
function c3775068.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁处理的伤害对象玩家设为对方的玩家（1-tp）。
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前连锁的伤害参数为800。
	Duel.SetTargetParam(800)
	-- 登记操作信息：本效果将给与对方玩家800点效果伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- 伤害效果处理：从连锁信息取出对象玩家和伤害值，实际给与对方800点效果伤害。
function c3775068.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取对象玩家和伤害参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对获取到的对象玩家造成800点效果伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
-- ③效果的发动条件：这张卡被对方效果送去墓地，且送去墓地前由自己控制。
function c3775068.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
-- 定义可特殊召唤的「方界」怪兽条件：拥有「方界」字段且能够用效果特殊召唤。
function c3775068.spfilter(c,e,tp)
	return c:IsSetCard(0xe3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的目标选择函数：检查选择的卡是否位于自己墓地且满足特殊召唤条件；效果发动时检查场上是否有空位、墓地是否有对象。
function c3775068.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c3775068.spfilter(chkc,e,tp) end
	-- 效果发动合法性检查：自己场上必须有可用怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且自己墓地存在至少1只符合条件的「方界」怪兽。
		and Duel.IsExistingTarget(c3775068.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	local ft=3
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 将可特殊召唤数量上限取为当前可用怪兽区域数（与青眼精灵龙限制后的3取较小值）。
	ft=math.min(ft,(Duel.GetLocationCount(tp,LOCATION_MZONE)))
	-- 显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1到ft张满足条件的「方界」怪兽作为效果对象，同时将这些卡记录为该连锁的对象。
	local g=Duel.SelectTarget(tp,c3775068.spfilter,tp,LOCATION_GRAVE,0,1,ft,nil,e,tp)
	-- 登记操作信息：本次效果将特殊召唤已选择的怪兽，数量为其张数。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 定义可加入手卡的「方界」卡的过滤条件：持有「方界」字段且可以被加入手卡。
function c3775068.thfilter(c)
	return c:IsSetCard(0xe3) and c:IsAbleToHand()
end
-- ③效果处理：取出仍与效果关联的对象怪兽；若同时特殊召唤2只以上且场上有青眼精灵龙则整个特殊召唤处理不执行；按可用区域压缩数量后表侧攻击表示特殊召唤；特殊召唤成功后可再从卡组·墓地选1张「方界」卡加入手卡。
function c3775068.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上当前可用的怪兽区域数量，若为0则结束处理。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 从连锁信息中取得对象怪兽组，并过滤掉已不再与效果关联（例如已离开墓地）的卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if g:GetCount()>ft then
		-- 显示“请选择要特殊召唤的卡”的选择提示（对象数量超出可用区域时进一步选择）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=g:Select(tp,ft,ft,nil)
	end
	-- 将选中的「方界」怪兽表侧攻击表示特殊召唤到自己场上，并检查是否至少有1只特殊召唤成功。
	if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 从自己的卡组·墓地中获取持有「方界」字段且可加入手卡的卡组（墓地部分受王家长眠之谷影响时会被过滤）。
		local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c3775068.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
		-- 若存在可加入手卡的「方界」卡，则询问玩家是否将1张「方界」卡加入手卡。
		if sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(3775068,2)) then  --"是否把1张「方界」卡加入手卡？"
			-- 显示“请选择要加入手牌的卡”的选择提示。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			sg=sg:Select(tp,1,1,nil)
			-- 中断当前连锁的效果处理，使后续的加入手卡与之前的特殊召唤不在同一时点，呼应效果原文的“那之后”。
			Duel.BreakEffect()
			-- 将选中的「方界」卡加入其持有者的手卡。
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 向对方玩家展示确认加入手卡的卡。
			Duel.ConfirmCards(1-tp,sg)
			-- 洗切卡组（从卡组检索后需要洗切）。
			Duel.ShuffleDeck(tp)
		end
	end
end
