--方界帝ゲイラ・ガイル
-- 效果：
-- 这张卡不能通常召唤。把自己场上1只「方界」怪兽送去墓地的场合可以特殊召唤。
-- ①：这个方法特殊召唤的这张卡的攻击力上升800。
-- ②：这张卡从手卡的特殊召唤成功的场合发动。给与对方800伤害。
-- ③：这张卡战斗的伤害步骤结束时，以自己墓地最多2只「方界胤 毗贾姆」为对象才能发动。这张卡送去墓地，作为对象的怪兽特殊召唤。那之后，可以从卡组把1只「方界帝 神火之德拉耆尼」加入手卡。
function c40392714.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。把自己场上1只「方界」怪兽送去墓地的场合可以特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c40392714.spcon)
	e2:SetOperation(c40392714.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡从手卡的特殊召唤成功的场合发动。给与对方800伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c40392714.damcon)
	e3:SetTarget(c40392714.damtg)
	e3:SetOperation(c40392714.damop)
	c:RegisterEffect(e3)
	-- ③：这张卡战斗的伤害步骤结束时，以自己墓地最多2只「方界胤 毗贾姆」为对象才能发动。这张卡送去墓地，作为对象的怪兽特殊召唤。那之后，可以从卡组把1只「方界帝 神火之德拉耆尼」加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DAMAGE_STEP_END)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 设置③效果的发动条件：在伤害步骤结束时，且这张卡与战斗相关（未离场或处于战斗破坏状态）才可发动。
	e4:SetCondition(aux.dsercon)
	e4:SetTarget(c40392714.sptg2)
	e4:SetOperation(c40392714.spop2)
	c:RegisterEffect(e4)
end
-- 过滤函数：选择可作为特殊召唤代价的「方界」怪兽，要求表侧表示、拥有「方界」字段、可作为cost送去墓地，并且在送墓后能空出可用的怪兽区（ft>0或位于主要怪兽区）。
function c40392714.filter(c,ft)
	return c:IsFaceup() and c:IsSetCard(0xe3) and c:IsAbleToGraveAsCost() and (ft>0 or c:GetSequence()<5)
end
-- 特殊召唤规则条件：当这张卡在手牌时，检查玩家场上是否存在1只以上可作为代价的「方界」怪兽，且怪兽区在送墓后至少有1个空位（ft>-1）。若c为nil，表示规则询问能否特殊召唤，返回true供系统判断。
function c40392714.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取当前玩家主要的怪兽区可用空格数，用于后续代价选择和确保特殊召唤后有格子。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 返回是否满足：怪兽区在送墓1只后仍有空位（ft>-1），且场上存在至少1只满足条件的「方界」怪兽可作为代价。
	return ft>-1 and Duel.IsExistingMatchingCard(c40392714.filter,tp,LOCATION_MZONE,0,1,nil,ft)
end
-- 特殊召唤手续处理：选择自己场上1只符合条件的「方界」怪兽作为代价送入墓地，完成特殊召唤；并为这张卡赋予『这个方法特殊召唤的这张卡的攻击力上升800』的永续效果（①的效果）。
function c40392714.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 计算当前主要怪兽区的可用空格数，供选择代价时判断能否在送墓后空出位置。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 显示“请选择要送去墓地的卡”的提示，引导玩家选择特殊召唤代价。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己场上选择1只满足filter的「方界」怪兽，作为特殊召唤的代价。
	local g=Duel.SelectMatchingCard(tp,c40392714.filter,tp,LOCATION_MZONE,0,1,1,nil,ft)
	-- 将选中的「方界」怪兽以COST（代价）形式送入墓地。
	Duel.SendtoGrave(g,REASON_COST)
	-- ①：这个方法特殊召唤的这张卡的攻击力上升800。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(800)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
end
-- ②效果的发动条件：这张卡从手卡特殊召唤成功时才发动，通过IsPreviousLocation(LOCATION_HAND)确认其之前在手卡区域。
function c40392714.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- ②效果的发动时处理：由于是必定给与对方800伤害的必发效果，无需选择对象；设置对象玩家为对方、伤害参数为800，并登记伤害操作信息。
function c40392714.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设为对方玩家（1-tp），表示伤害承受方。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数设为800，表示造成的伤害数值。
	Duel.SetTargetParam(800)
	-- 登记操作信息：此效果属于伤害效果，对象玩家为对方，伤害值为800，供其他卡牌响应检测。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- ②效果的实际处理：从连锁信息中读取对象玩家和伤害值，对对方造成效果伤害。
function c40392714.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取之前设置的对象玩家和对象参数，即要伤害的玩家和伤害值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害的方式，对目标玩家造成指定数值的伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 过滤函数：选择墓地的「方界胤 毗贾姆」（卡号15610297）作为特殊召唤对象，要求该怪兽能被当前效果特殊召唤。
function c40392714.spfilter(c,e,tp)
	return c:IsCode(15610297) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的发动目标设定：若检查对象合法性，则对象必须在己方墓地且满足spfilter；若为发动时判定，则需己方怪兽区有空格、本卡进行了战斗，并且墓地存在可特殊召唤的「方界胤 毗贾姆」。
function c40392714.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c40392714.spfilter(chkc,e,tp) end
	-- ③效果发动条件之一：自己场上怪兽区有空格可特殊召唤对象，且这张卡与战斗相关（进行了那次战斗）。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler(),tp)>0 and c:IsRelateToBattle()
		-- ③效果发动条件之二：墓地存在至少1只满足特殊召唤条件的「方界胤 毗贾姆」可以作为对象。
		and Duel.IsExistingTarget(c40392714.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	local ft=2
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 计算可选对象数量上限：取2与当前剩余怪兽区空格数的较小值，防止选择过多导致后续无法全部特殊召唤。
	ft=math.min(ft,(Duel.GetMZoneCount(tp,e:GetHandler(),tp)))
	-- 显示“请选择要特殊召唤的卡”的提示，准备选择墓地的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1～ft只满足spfilter的「方界胤 毗贾姆」作为效果对象，并登记为连锁对象。
	local g=Duel.SelectTarget(tp,c40392714.spfilter,tp,LOCATION_GRAVE,0,1,ft,nil,e,tp)
	-- 设置连锁操作信息：本次效果将特殊召唤所选择的对象，数量为对象数量，供相关效果响应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 过滤函数：用于检索卡组中的「方界帝 神火之德拉耆尼」（卡号77387463），要求其能够加入手卡。
function c40392714.thfilter(c)
	return c:IsCode(77387463) and c:IsAbleToHand()
end
-- ③效果处理：先将这张卡自身送去墓地；若成功且怪兽区有空位，则将仍与效果相关的对象「方界胤 毗贾姆」特殊召唤；特殊召唤成功后，再询问是否从卡组将1只「方界帝 神火之德拉耆尼」加入手卡。同时处理了青眼精灵龙限制同时特殊召唤2只以上怪兽的情况。
function c40392714.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与效果相关后，以效果将其送去墓地；若已离场或送墓失败，则整个效果不处理。
	if not c:IsRelateToEffect(e) or Duel.SendtoGrave(c,REASON_EFFECT)==0 then return end
	-- 获取当前玩家可用的怪兽区空格数，用于判断是否还有格子特殊召唤对象。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 从连锁信息中取得之前选择的对象卡组，并过滤出仍与该效果有关联的卡（未离开墓地等）。
	local sg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if sg:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if sg:GetCount()>ft then
		-- 若仍有效对象数量超过可用空格，显示“请选择要特殊召唤的卡”提示，并从中选择实际能特殊召唤的数量。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		sg=sg:Select(tp,ft,ft,nil)
	end
	-- 将筛选后的「方界胤 毗贾姆」特殊召唤到己方场上；若特殊召唤成功，则继续处理后续的检索。
	if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 从卡组中搜索所有可加入手卡的「方界帝 神火之德拉耆尼」。
		local g=Duel.GetMatchingGroup(c40392714.thfilter,tp,LOCATION_DECK,0,nil)
		-- 若卡组存在检索目标且玩家确认“是”，则执行追加检索操作（对应“那之后，可以从卡组把1只「方界帝 神火之德拉耆尼」加入手卡”）。
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(40392714,0)) then  --"是否把1只「方界帝 神火之德拉耆尼」加入手卡？"
			-- 中断当前效果处理，使之后的检索作为独立处理，避免错过时点（即“那之后”的另行动）。
			Duel.BreakEffect()
			-- 显示“请选择要加入手牌的卡”提示，准备从卡组选择检索目标。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			g=g:Select(tp,1,1,nil)
			-- 将选中的「方界帝 神火之德拉耆尼」加入手卡。
			Duel.SendtoHand(g,tp,REASON_EFFECT)
			-- 让对方玩家确认加入手卡的卡，以公开检索到的卡片信息。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
