--R.B.オペレーション・テスト
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的发动时，可以以自己墓地1只3星以上的「反叛曲机器人」怪兽为对象。那个场合，那只怪兽特殊召唤。
-- ②：以自己场上的「反叛曲机器人」怪兽任意数量为对象才能发动。自己基本分回复那些怪兽的原本攻击力的合计数值，那些怪兽回到手卡·额外卡组。那之后，可以从手卡把1只「反叛曲机器人」怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，分别注册作为永续魔法卡发动并可选择苏生墓地怪兽的①效果以及②的回复基本分、回手与手卡特召起动效果
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张，①：这张卡的发动时，可以以自己墓地1只3星以上的「反叛曲机器人」怪兽为对象。那个场合，那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：以自己场上的「反叛曲机器人」怪兽任意数量为对象才能发动。自己基本分回复那些怪兽的原本攻击力的合计数值，那些怪兽回到手卡·额外卡组。那之后，可以从手卡把1只「反叛曲机器人」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回复基本分"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_TOEXTRA+CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地中可作为①效果对象的怪兽：等级在3星以上、属于「反叛曲机器人」字段，且场上仍有怪兽区空位可供其特殊召唤
function s.spfilter(c,e,tp)
	return c:IsLevelAbove(3) and c:IsSetCard(0x1cf)
		-- 检查自己主要怪兽区是否还有至少1个可用空格
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 处理卡的发动时的目标选择：可空发，若墓地有符合条件的怪兽且玩家选择发动对应效果，则取1只为对象并设置特殊召唤操作信息，否则重置效果属性为空发
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return true end
	-- 检查自己墓地是否存在至少1只满足特殊召唤条件的3星以上「反叛曲机器人」怪兽可成为对象
	if Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 询问发动玩家是否要在发动这张卡时适用墓地特殊召唤的效果
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否要选卡？"
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetOperation(s.activate)
		-- 向发动玩家发送选择效果对象的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 让发动玩家从自己墓地选择1只符合条件的怪兽作为本次连锁的对象
		local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		-- 登记本次连锁包含将对象怪兽特殊召唤的操作信息
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	else
		e:SetCategory(0)
		e:SetProperty(0)
		e:SetOperation(nil)
	end
end
-- 执行①效果处理：检查对象怪兽是否仍与连锁关联且未受王家长眠之谷限制，符合条件则将其表侧表示特殊召唤到自己场上
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选中的墓地对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() then
		-- 检查目标是否受王家长眠之谷效果干涉，若被其无效则中止后续处理
		if aux.NecroValleyNegateCheck(tc) then return end
		-- 再次确认对象怪兽不受王家长眠之谷限制，否则中止特殊召唤
		if not aux.NecroValleyFilter()(tc) then return end
		-- 将对象怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤自己场上可作为②效果对象的怪兽：表侧表示、属于「反叛曲机器人」字段、能够回到手卡（或额外卡组）且可以成为效果对象
function s.thfilter(c,e)
	return c:IsFaceup() and c:IsSetCard(0x1cf) and c:IsAbleToHand() and c:IsCanBeEffectTarget(e)
end
-- 检查选中的怪兽子集其原本攻击力之和是否大于0
function s.gcheck(g)
	return g:GetSum(Card.GetBaseAttack)>0
end
-- ②效果发动检查与取对象处理：检查存在原本攻击力合计大于0的「反叛曲机器人」怪兽组合，让玩家任选至少1只作为对象，并登记返回手卡与回复基本分的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己场上所有符合②效果对象条件的「反叛曲机器人」怪兽
	local tg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_MZONE,0,nil,e)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.thfilter(chkc,e) end
	if chk==0 then return tg:CheckSubGroup(s.gcheck,1,99) end
	-- 向发动玩家发送选择要返回手卡（或额外卡组）的卡片提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local g=tg:SelectSubGroup(tp,s.gcheck,false,1,99)
	-- 登记本次连锁包含将选定数量的怪兽返回手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
	-- 将选出的怪兽卡片组设定为当前连锁的对象
	Duel.SetTargetCard(g)
	-- 将选中怪兽的原本攻击力合计数值设为连锁对象参数
	Duel.SetTargetParam(g:GetSum(Card.GetBaseAttack))
	-- 登记本次连锁包含使自己回复对应数值基本分的操作信息
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetSum(Card.GetBaseAttack))
end
-- 过滤手卡中可被②效果特殊召唤的「反叛曲机器人」怪兽
function s.spfilter2(c,e,tp)
	return c:IsSetCard(0x1cf)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 执行②效果处理：使自己回复与连锁关联的对象怪兽原本攻击力合计等量的基本分，将这些怪兽回到手卡·额外卡组，若至少有1只返回手卡或额外卡组且可从手卡特召，则询问玩家并可从手卡特殊召唤1只「反叛曲机器人」怪兽
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取所有仍与当前连锁保持关联的对象怪兽卡片组
	local g=Duel.GetTargetsRelateToChain()
	-- 检查存在关联对象并使自己以效果回复这些怪兽原本攻击力合计的基本分，且实际回复量不为0
	if g:GetCount()>0 and Duel.Recover(tp,g:GetSum(Card.GetBaseAttack),REASON_EFFECT)~=0
		-- 将那些对象怪兽以效果返回持有者的手卡（额外卡组怪兽会自动回到额外卡组）并确认至少有1只操作成功
		and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
		-- 获取刚刚被返回手卡·额外卡组操作实际移动了的卡片组
		local og=Duel.GetOperatedGroup()
		if og:IsExists(Card.IsLocation,1,nil,LOCATION_HAND+LOCATION_EXTRA)
			-- 检查自己主要怪兽区是否仍有至少1个空格可供特殊召唤
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查自己手卡中是否存在至少1只可特殊召唤的「反叛曲机器人」怪兽
			and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND,0,1,nil,e,tp)
			-- 询问发动玩家是否要从手卡特殊召唤1只怪兽
			and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否从手卡特殊召唤？"
			-- 向发动玩家发送选择要特殊召唤的卡片的提示
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 让发动玩家从自己手卡选择1只符合条件的「反叛曲机器人」怪兽
			local sg=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_HAND,0,1,1,nil,e,tp)
			if sg:GetCount()>0 then
				-- 中断当前效果处理流程，使之后的特殊召唤视为“那之后”的非同时处理
				Duel.BreakEffect()
				-- 将从手卡选出的「反叛曲机器人」怪兽以表侧表示特殊召唤到自己场上
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
