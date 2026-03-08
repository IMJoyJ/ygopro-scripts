--方界獣ダーク・ガネックス
-- 效果：
-- 这张卡不能通常召唤。把自己场上1只「方界」怪兽送去墓地的场合可以特殊召唤。
-- ①：这个方法特殊召唤的这张卡的攻击力上升1000。
-- ②：这张卡战斗破坏怪兽时，以自己墓地最多2只「方界胤 毗贾姆」为对象才能发动。这张卡送去墓地，作为对象的怪兽特殊召唤。那之后，可以从卡组把1只「方界兽 利刃之迦楼迪亚」加入手卡。
function c41114306.initial_effect(c)
	c:EnableReviveLimit()
	-- 这个效果用于特殊召唤方界兽 暗黑之甘尼克斯，需要将自己场上1只「方界」怪兽送去墓地作为条件
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
	-- 检测当前怪兽是否参与了战斗破坏怪兽的处理
	e3:SetCondition(aux.bdcon)
	e3:SetTarget(c41114306.sptg2)
	e3:SetOperation(c41114306.spop2)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选自己场上满足条件的「方界」怪兽（必须是表侧表示、属于「方界」卡组、可以送去墓地、且场上还有空位）
function c41114306.filter(c,tp)
	-- 满足表侧表示、属于「方界」卡组、可以送去墓地、且场上还有空位的条件
	return c:IsFaceup() and c:IsSetCard(0xe3) and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 判断是否满足特殊召唤条件，即自己场上是否存在满足条件的「方界」怪兽
function c41114306.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断自己场上是否存在至少1只满足条件的「方界」怪兽
	return Duel.IsExistingMatchingCard(c41114306.filter,tp,LOCATION_MZONE,0,1,nil,tp)
end
-- 选择要送去墓地的「方界」怪兽，并设置为效果的标签对象
function c41114306.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足条件的「方界」怪兽组
	local g=Duel.GetMatchingGroup(c41114306.filter,tp,LOCATION_MZONE,0,nil,tp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 将选择的怪兽送去墓地，并为这张卡增加1000攻击力
function c41114306.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选择的怪兽送去墓地
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	-- 为这张卡增加1000攻击力
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(1000)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选墓地中的「方界兽 利刃之迦楼迪亚」
function c41114306.spfilter(c,e,tp)
	return c:IsCode(15610297) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的目标为墓地中的「方界胤 毗贾姆」
function c41114306.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c41114306.spfilter(chkc,e,tp) end
	-- 判断是否有足够的怪兽区域进行特殊召唤
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler(),tp)>0
		-- 判断墓地是否存在至少1只「方界胤 毗贾姆」
		and Duel.IsExistingTarget(c41114306.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	local ft=2
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 限制选择的「方界胤 毗贾姆」数量不超过可用怪兽区数量
	ft=math.min(ft,(Duel.GetMZoneCount(tp,e:GetHandler(),tp)))
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽进行特殊召唤
	local g=Duel.SelectTarget(tp,c41114306.spfilter,tp,LOCATION_GRAVE,0,1,ft,nil,e,tp)
	-- 设置连锁操作信息，表示将要特殊召唤目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 过滤函数，用于筛选卡组中的「方界兽 利刃之迦楼迪亚」
function c41114306.thfilter(c)
	return c:IsCode(78509901) and c:IsAbleToHand()
end
-- 处理效果的发动，将这张卡送去墓地，特殊召唤目标怪兽，并可选择加入手牌
function c41114306.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断这张卡是否仍然在场上且成功送去墓地
	if not c:IsRelateToEffect(e) or Duel.SendtoGrave(c,REASON_EFFECT)==0 then return end
	-- 获取玩家场上可用的怪兽区数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 获取连锁中指定的目标卡片组
	local sg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if sg:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if sg:GetCount()>ft then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		sg=sg:Select(tp,ft,ft,nil)
	end
	-- 将目标怪兽特殊召唤到场上
	if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取卡组中满足条件的「方界兽 利刃之迦楼迪亚」
		local g=Duel.GetMatchingGroup(c41114306.thfilter,tp,LOCATION_DECK,0,nil)
		-- 询问玩家是否将1只「方界兽 利刃之迦楼迪亚」加入手牌
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(41114306,0)) then  --"是否把1只「方界兽 利刃之迦楼迪亚」加入手卡？"
			-- 中断当前效果处理，使后续处理视为不同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			g=g:Select(tp,1,1,nil)
			-- 将选择的卡加入手牌
			Duel.SendtoHand(g,tp,REASON_EFFECT)
			-- 向对方确认加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
