--粛声なる祝福
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以「肃声之祝福」以外的自己的墓地·除外状态的1张「肃声」卡为对象才能发动。那张卡加入手卡。
-- ②：仪式怪兽以外的怪兽表侧表示召唤·特殊召唤的场合才能发动。等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从手卡把1只战士族·龙族而光属性的仪式怪兽仪式召唤。这个效果特殊召唤的怪兽不会被战斗破坏。
function c39114494.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以「肃声之祝福」以外的自己的墓地·除外状态的1张「肃声」卡为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39114494,1))  --"回收「肃声」卡"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,39114494)
	e2:SetTarget(c39114494.thtg)
	e2:SetOperation(c39114494.thop)
	c:RegisterEffect(e2)
	-- ②：仪式怪兽以外的怪兽表侧表示召唤·特殊召唤的场合才能发动。等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从手卡把1只战士族·龙族而光属性的仪式怪兽仪式召唤。这个效果特殊召唤的怪兽不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(39114494,2))  --"仪式召唤战士族·龙族光属性仪式怪兽"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,39114495)
	e3:SetCondition(c39114494.ricon)
	e3:SetTarget(c39114494.ritg)
	e3:SetOperation(c39114494.riop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于筛选满足条件的「肃声」卡（非本卡、表侧表示、属于肃声卡组、可以加入手牌）
function c39114494.filter(c,e,tp)
	return not c:IsCode(39114494) and c:IsFaceupEx() and c:IsSetCard(0x1a6) and c:IsAbleToHand()
end
-- 效果处理时的Target阶段，检查是否存在满足条件的「肃声」卡作为对象
function c39114494.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and c39114494.filter(chkc,e,tp) end
	-- 检查是否存在满足条件的「肃声」卡作为对象
	if chk==0 then return Duel.IsExistingTarget(c39114494.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「肃声」卡作为对象
	local tc=Duel.SelectTarget(tp,c39114494.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp):GetFirst()
	if tc:IsLocation(LOCATION_GRAVE) then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
		-- 设置操作信息，标记该卡将从墓地离开
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,tc,1,0,0)
	else
		e:SetCategory(CATEGORY_TOHAND)
	end
end
-- 效果处理阶段，将目标卡加入手牌
function c39114494.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标卡
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	if tc then
		-- 将目标卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 过滤函数，用于筛选满足条件的非仪式怪兽（表侧表示）
function c39114494.cfilter(c)
	return c:IsFaceup() and not c:IsType(TYPE_RITUAL)
end
-- 触发条件函数，判断是否有非仪式怪兽被召唤或特殊召唤成功
function c39114494.ricon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c39114494.cfilter,1,nil)
end
-- 过滤函数，用于筛选满足条件的战士族·龙族·光属性仪式怪兽
function c39114494.rfilter(c,e,tp)
	return c:IsType(TYPE_RITUAL) and (c:IsRace(RACE_DRAGON) or c:IsRace(RACE_WARRIOR)) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 效果处理时的Target阶段，检查是否存在满足条件的仪式怪兽可被仪式召唤
function c39114494.ritg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取玩家可用的仪式召唤素材组（手牌、场上、墓地）
		local mg=Duel.GetRitualMaterial(tp)
		-- 检查是否存在满足条件的仪式怪兽可被仪式召唤
		return Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,nil,c39114494.rfilter,e,tp,mg,nil,Card.GetLevel,"Greater")
	end
	-- 设置操作信息，标记将特殊召唤仪式怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理阶段，进行仪式召唤操作
function c39114494.riop(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	-- 获取玩家可用的仪式召唤素材组（手牌、场上、墓地）
	local mg=Duel.GetRitualMaterial(tp)
	-- 提示玩家选择要特殊召唤的仪式怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的仪式怪兽作为仪式召唤对象
	local tg=Duel.SelectMatchingCard(tp,aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,1,nil,c39114494.rfilter,e,tp,mg,nil,Card.GetLevel,"Greater")
	local tc=tg:GetFirst()
	if tc then
		mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		-- 提示玩家选择要解放的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 设置附加检查函数，用于等级合计验证
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Greater")
		-- 从可用素材中选择满足等级要求的卡组作为祭品
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Greater")
		-- 清除附加检查函数
		aux.GCheckAdditional=nil
		if not mat then goto cancel end
		tc:SetMaterial(mat)
		local lv=mat:GetSum(Card.GetLevel)
		-- 解放仪式召唤用的祭品
		Duel.ReleaseRitualMaterial(mat)
		-- 中断当前效果，使之后的效果处理视为不同时处理
		Duel.BreakEffect()
		-- 特殊召唤仪式怪兽
		if Duel.SpecialSummonStep(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP) then
			-- 「肃声之祝福」效果适用中，不会被战斗破坏
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(39114494,3))  --"「肃声之祝福」效果适用中，不会被战斗破坏"
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetRange(LOCATION_MZONE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			tc:CompleteProcedure()
		end
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
end
