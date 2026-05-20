--インペリアル・バウアー
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：自己场上没有其他怪兽存在的场合，把这张卡解放才能发动。从卡组选「王后骑士」「卫兵骑士」「国王骑士」之内2只（同名卡最多1张）。那些怪兽各加入手卡或特殊召唤。
function c56673112.initial_effect(c)
	-- 注册本卡效果中提及的「王后骑士」、「卫兵骑士」、「国王骑士」的卡片密码，用于卡片关联检索。
	aux.AddCodeList(c,25652259,64788463,90876561)
	-- 这个卡名的效果1回合只能使用1次。①：自己场上没有其他怪兽存在的场合，把这张卡解放才能发动。从卡组选「王后骑士」「卫兵骑士」「国王骑士」之内2只（同名卡最多1张）。那些怪兽各加入手卡或特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56673112,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,56673112)
	e1:SetCondition(c56673112.spcon)
	e1:SetCost(c56673112.spcost)
	e1:SetTarget(c56673112.sptg)
	e1:SetOperation(c56673112.spop)
	c:RegisterEffect(e1)
end
-- 效果发动条件判定：自己场上没有其他怪兽存在。
function c56673112.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽数量是否等于1（因为此卡在场，数量为1即代表没有其他怪兽）。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==1
end
-- 效果发动代价处理：解放这张卡。
function c56673112.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤卡组中属于「王后骑士」、「卫兵骑士」、「国王骑士」且可以加入手牌或特殊召唤的怪兽。
function c56673112.opfilter(c,e,tp,ft)
	return (c:IsAbleToHand() or c:IsCanBeSpecialSummoned(e,0,tp,false,false) and ft>0) and c:IsCode(64788463,25652259,90876561)
end
-- 检查选出的2张卡是否同名卡最多1张，且满足加入手牌或特殊召唤的条件。
function c56673112.opcheck(g,e,tp,ft)
	if g:GetClassCount(Card.GetCode)<2 then return false end
	local thct=g:FilterCount(Card.IsAbleToHand,nil)
	local spct=g:FilterCount(Card.IsCanBeSpecialSummoned,nil,e,0,tp,false,false)
	return thct+math.min(spct,ft)>=2
end
-- 效果发动目标判定：检查卡组中是否存在满足条件的2张卡。
function c56673112.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取此卡解放后，自己场上可用的怪兽区域数量。
		local ft=Duel.GetMZoneCount(tp,e:GetHandler())
		if ft<0 then ft=0 end
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if ft>0 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		-- 获取卡组中所有符合条件的「王后骑士」、「卫兵骑士」、「国王骑士」怪兽。
		local g=Duel.GetMatchingGroup(c56673112.opfilter,tp,LOCATION_DECK,0,nil,e,tp,ft)
		return g:CheckSubGroup(c56673112.opcheck,2,2,e,tp,ft)
	end
end
-- 效果处理：从卡组选择2只怪兽，分别加入手牌或特殊召唤。
function c56673112.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前自己场上可用的怪兽区域数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<0 then ft=0 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>0 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取卡组中所有符合条件的「王后骑士」、「卫兵骑士」、「国王骑士」怪兽。
	local g=Duel.GetMatchingGroup(c56673112.opfilter,tp,LOCATION_DECK,0,nil,e,tp,ft)
	-- 提示玩家选择要操作的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	local sg=g:SelectSubGroup(tp,c56673112.opcheck,false,2,2,e,tp,ft)
	if not sg then return end
	local thsg=Group.CreateGroup()
	local spsg=Group.CreateGroup()
	local thct=sg:FilterCount(Card.IsAbleToHand,nil)
	local spct=sg:FilterCount(Card.IsCanBeSpecialSummoned,nil,e,0,tp,false,false)
	if thct==0 then
		spsg=sg
	elseif spct==0 or ft==0 then
		thsg=sg
	else
		-- 询问玩家是否要将选出的怪兽加入手牌（若怪兽区域不足2个则必须选择加入手牌）。
		if Duel.SelectYesNo(tp,aux.Stringid(56673112,1)) or ft<2 then  --"是否从中把怪兽加入手卡？"
			-- 提示玩家选择要加入手牌的卡片。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			thsg=sg:FilterSelect(tp,Card.IsAbleToHand,1,thct,nil)
			spsg=sg-thsg
		else
			spsg=sg
		end
	end
	if #thsg>0 then
		-- 将选定的怪兽加入手牌。
		Duel.SendtoHand(thsg,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片。
		Duel.ConfirmCards(1-tp,thsg)
	end
	if #spsg>0 then
		-- 将选定的怪兽以表侧表示特殊召唤。
		Duel.SpecialSummon(spsg,0,tp,tp,false,false,POS_FACEUP)
	end
end
