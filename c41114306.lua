--方界獣ダーク・ガネックス
-- 效果：
-- 这张卡不能通常召唤。把自己场上1只「方界」怪兽送去墓地的场合可以特殊召唤。
-- ①：这个方法特殊召唤的这张卡的攻击力上升1000。
-- ②：这张卡战斗破坏怪兽时，以自己墓地最多2只「方界胤 毗贾姆」为对象才能发动。这张卡送去墓地，作为对象的怪兽特殊召唤。那之后，可以从卡组把1只「方界兽 利刃之迦楼迪亚」加入手卡。
function c41114306.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。把自己场上1只「方界」怪兽送去墓地的场合可以特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c41114306.spcon)
	e2:SetTarget(c41114306.sptg)
	e2:SetOperation(c41114306.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡战斗破坏怪兽时，以自己墓地最多2只「方界胤 毗贾姆」为对象才能发动。这张卡送去墓地，作为对象的怪兽特殊召唤。那之后，可以从卡组把1只「方界兽 利刃之迦楼迪亚」加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 设置触发条件：此卡与本次战斗有关（即此卡战斗破坏了怪兽）。
	e3:SetCondition(aux.bdcon)
	e3:SetTarget(c41114306.sptg2)
	e3:SetOperation(c41114306.spop2)
	c:RegisterEffect(e3)
end
-- 定义召唤代价的筛选函数：选择自己场上表侧表示、属于「方界」字段、可作为代价送去墓地，且送墓后自己场上仍有空位可供特殊召唤的怪兽。
function c41114306.filter(c,tp)
	-- 筛选条件为：表侧表示、属于「方界」字段、可作为代价送去墓地，且送墓后自己场上仍有空闲怪兽区。
	return c:IsFaceup() and c:IsSetCard(0xe3) and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤规则的条件函数：检查自己场上是否存在至少1只满足召唤代价条件的「方界」怪兽。
function c41114306.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检测自己场上是否存在至少1只满足filter条件的「方界」怪兽作为召唤代价。
	return Duel.IsExistingMatchingCard(c41114306.filter,tp,LOCATION_MZONE,0,1,nil,tp)
end
-- 特殊召唤规则的选择代价函数：列出满足条件的「方界」怪兽，由玩家选择1只作为召唤代价，并记录到效果标签中。
function c41114306.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上所有满足召唤代价条件的「方界」怪兽集合。
	local g=Duel.GetMatchingGroup(c41114306.filter,tp,LOCATION_MZONE,0,nil,tp)
	-- 显示“请选择要送去墓地的卡”的提示，引导玩家选择召唤代价怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的实际处理：将选择的「方界」怪兽送去墓地，并给成功特殊召唤的这张卡赋予攻击力上升1000的效果。
function c41114306.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选择的代价怪兽以特殊召唤规则送墓的代价送去墓地。
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	-- ①：这个方法特殊召唤的这张卡的攻击力上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(1000)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
end
-- 定义「方界胤 毗贾姆」的筛选条件：卡号是15610297且可以被特殊召唤。
function c41114306.spfilter(c,e,tp)
	return c:IsCode(15610297) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件和取对象处理：在战斗破坏怪兽的时点，检查自己场上是否有空位以及墓地是否存在可特殊召唤的「方界胤 毗贾姆」作为对象。
function c41114306.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c41114306.spfilter(chkc,e,tp) end
	-- 效果发动时检查：这张卡从场上离开后，自己场上是否仍有可用的怪兽区空格。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler(),tp)>0
		-- 同时检查自己墓地是否存在至少1只满足条件且可特殊召唤的「方界胤 毗贾姆」作为效果对象。
		and Duel.IsExistingTarget(c41114306.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	local ft=2
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 计算本次可选择的“方界胤 毗贾姆”数量的上限，取规则限制（如青眼精灵龙）和剩余怪兽区空格数中的较小值。
	ft=math.min(ft,(Duel.GetMZoneCount(tp,e:GetHandler(),tp)))
	-- 显示“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地的符合条件的“方界胤 毗贾姆”中选择1至最多ft只作为效果对象，并自动设置为连锁对象。
	local g=Duel.SelectTarget(tp,c41114306.spfilter,tp,LOCATION_GRAVE,0,1,ft,nil,e,tp)
	-- 设置效果处理信息：本次效果将把选择的对象怪兽特殊召唤，供后续连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 定义「方界兽 利刃之迦楼迪亚」的筛选条件：卡号是78509901且可以加入手卡。
function c41114306.thfilter(c)
	return c:IsCode(78509901) and c:IsAbleToHand()
end
-- ②效果的处理：将这张卡自身送去墓地，特殊召唤对象怪兽；成功后可选是否从卡组把1只「方界兽 利刃之迦楼迪亚」加入手卡。
function c41114306.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认本卡仍与效果关联，并将本卡以效果原因送去墓地；若本卡已不关联或送墓失败，则结束效果处理。
	if not c:IsRelateToEffect(e) or Duel.SendtoGrave(c,REASON_EFFECT)==0 then return end
	-- 获取自己场上当前可用的怪兽区空格数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 从连锁的对象卡中筛选出仍与本次效果关联的「方界胤 毗贾姆」（即仍然可以特殊召唤的对象）。
	local sg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if sg:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if sg:GetCount()>ft then
		-- 显示“请选择要特殊召唤的卡”的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		sg=sg:Select(tp,ft,ft,nil)
	end
	-- 若对象怪兽特殊召唤成功（返回特殊召唤数量不为0），则继续处理后续的检索效果。
	if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 从卡组中获取所有满足条件的「方界兽 利刃之迦楼迪亚」的集合。
		local g=Duel.GetMatchingGroup(c41114306.thfilter,tp,LOCATION_DECK,0,nil)
		-- 若卡组中存在「方界兽 利刃之迦楼迪亚」且玩家选择“是”，则执行加入手卡的处理。
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(41114306,0)) then  --"是否把1只「方界兽 利刃之迦楼迪亚」加入手卡？"
			-- 中断当前效果处理，使后续的检索加入手卡视为不同时处理，以避免错过时点。
			Duel.BreakEffect()
			-- 显示“请选择要加入手牌的卡”的提示信息。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			g=g:Select(tp,1,1,nil)
			-- 将选中的「方界兽 利刃之迦楼迪亚」加入持有者的手卡。
			Duel.SendtoHand(g,tp,REASON_EFFECT)
			-- 向对方玩家确认（展示）加入手卡的卡片。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
