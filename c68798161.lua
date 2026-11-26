--サラブレッド・エルフ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。从卡组把1张装备魔法卡送去墓地。那之后，这张卡的攻击力直到对方回合结束时上升500。
-- ②：这张卡战斗破坏对方怪兽时才能发动。从卡组选除「优秀精灵」外的1只4星以下的魔法师族·光属性怪兽加入手卡或特殊召唤。
local s,id,o=GetID()
-- 初始化「优秀精灵」(68798161)：注册①主要阶段将卡组装备魔法送墓并加攻的起动效果与②战斗破坏对方怪兽时检索或特召低星光属性魔法师族怪兽的触发效果
function s.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己主要阶段才能发动。从卡组把1张装备魔法卡送去墓地。那之后，
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏对方怪兽时才能发动。从卡组选除「优秀精灵」外的1只4星以下的魔法师族·光属性怪兽加入手卡或特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"卡组操作"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	-- 设置效果②的Condition函数为aux.bdocon（检查这张卡是否与本次战斗破坏对方怪兽的战斗相关）
	e2:SetCondition(aux.bdocon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数：筛选卡组中可以送去墓地的装备魔法卡
function s.tgfilter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToGrave()
end
-- 效果①的Target函数：检测己方卡组中存在可送墓的装备魔法卡，并设置从卡组把1张卡送去墓地的操作信息
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测时确认己方卡组中存在至少1张可送去墓地的装备魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置从己方卡组把1张卡送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果①的Operation函数：从卡组选1张装备魔法卡送去墓地，成功入墓且这张卡表侧在场时，使这张卡攻击力直到对方回合结束时上升500
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向己方玩家发送选择要送去墓地的装备魔法卡提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从己方卡组中选择1张可送去墓地的装备魔法卡
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 以效果将选中的装备魔法卡送去墓地，并确认其成功进入墓地
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)
		and c:IsFaceup() and c:IsRelateToChain() then
		-- 中断当前处理步骤，使后续攻击力上升与前面的送去墓地视为不同时处理（“那之后”）
		Duel.BreakEffect()
		-- 这张卡的攻击力直到对方回合结束时上升500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		c:RegisterEffect(e1)
	end
end
-- 过滤函数：筛选卡组中除「优秀精灵」(id)外的4星以下、光属性、魔法师族怪兽，且可加入手卡或在有空位时可特殊召唤
function s.thfilter(c,e,tp)
	if not (not c:IsCode(id) and c:IsLevelBelow(4) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_SPELLCASTER)) then return false end
	-- 获取己方主要怪兽区当前的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 效果②的Target函数：检测己方卡组中存在至少1只符合检索或特召条件的4星以下光属性魔法师族怪兽
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测时确认己方卡组中存在至少1只符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
end
-- 效果②的Operation函数：从卡组选1只除同名卡外的4星以下光属性魔法师族怪兽，根据可操作性及玩家选择加入手卡或表侧特殊召唤
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向己方玩家发送选择要操作的卡片提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从己方卡组中选择1只符合条件的4星以下光属性魔法师族怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 获取己方主要怪兽区当前的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tc=g:GetFirst()
	if tc then
		local flag=ft>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 若该卡可加入手卡，且无法特召（flag为false）或玩家在加入手卡(1190)与特召(1152)间选择了加入手卡，则执行回手分支
		if tc:IsAbleToHand() and (not flag or Duel.SelectOption(tp,1190,1152)==0) then
			-- 以效果将选中的怪兽加入持有者（己方）手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方玩家公开确认加入手卡的怪兽
			Duel.ConfirmCards(1-tp,tc)
		elseif flag then
			-- 当满足特召条件且未选回手时，将选中的怪兽以表侧表示特殊召唤到己方场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
