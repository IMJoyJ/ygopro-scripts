--R.B.オペレーション・テスト
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的发动时，可以以自己墓地1只3星以上的「反叛曲机器人」怪兽为对象。那个场合，那只怪兽特殊召唤。
-- ②：以自己场上的「反叛曲机器人」怪兽任意数量为对象才能发动。自己基本分回复那些怪兽的原本攻击力的合计数值，那些怪兽回到手卡·额外卡组。那之后，可以从手卡把1只「反叛曲机器人」怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：注册①效果（魔陷卡发动，自由时点，同名卡1回合只能发动1张）和②效果（魔陷区发动的起动效果，取对象，含特殊召唤·回手卡·回额外卡组·回复分类，1回合只能使用1次）
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
	-- ②：这个卡名的②的效果1回合只能使用1次。以自己场上的「反叛曲机器人」怪兽任意数量为对象才能发动。自己基本分回复那些怪兽的原本攻击力的合计数值，那些怪兽回到手卡·额外卡组。那之后，可以从手卡把1只「反叛曲机器人」怪兽特殊召唤。
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
-- 特殊召唤对象过滤函数：检查卡为3星以上的「反叛曲机器人」怪兽、自己场上存在可用的主要怪兽区空格、且该卡可以被此效果特殊召唤
function s.spfilter(c,e,tp)
	return c:IsLevelAbove(3) and c:IsSetCard(0x1cf)
		-- 并且自己场上存在1个及以上可用的主要怪兽区空格
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的对象选择处理：若自己墓地存在可作为对象的3星以上「反叛曲机器人」怪兽且玩家选择发动，则设定特殊召唤分类并选取该怪兽为对象；否则此卡仅作单纯的魔陷卡发动，不附带任何效果处理
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return true end
	-- 检查自己墓地是否存在至少1只满足条件且能成为效果对象的3星以上「反叛曲机器人」怪兽
	if Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 并询问玩家是否要选择那只怪兽为对象（玩家选择"是"才继续）
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否要选卡？"
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetOperation(s.activate)
		-- 向玩家发送"请选择效果的对象"的选择提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 让玩家从自己墓地选择1只3星以上的「反叛曲机器人」怪兽作为效果对象
		local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		-- 设置连锁操作信息：预定将对象的那1只怪兽特殊召唤
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	else
		e:SetCategory(0)
		e:SetProperty(0)
		e:SetOperation(nil)
	end
end
-- ①效果的处理：取得对象怪兽，若其仍与此连锁相关，则进行王家长眠之谷相关检查后将其表侧表示特殊召唤
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() then
		-- 检查对象是否受王家长眠之谷影响，若受影响且连锁可被无效则自动无效该连锁并中断处理
		if aux.NecroValleyNegateCheck(tc) then return end
		-- 若对象因王家长眠之谷而需被除外处理，则中断此次特殊召唤
		if not aux.NecroValleyFilter()(tc) then return end
		-- 将对象怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 返回手卡对象过滤函数：检查卡为表侧表示的「反叛曲机器人」怪兽、可以回到手卡（或额外卡组）、且能成为此效果的对象
function s.thfilter(c,e)
	return c:IsFaceup() and c:IsSetCard(0x1cf) and c:IsAbleToHand() and c:IsCanBeEffectTarget(e)
end
-- 子分组检查函数：所选怪兽组的原本攻击力合计必须大于0（确保能回复基本分）
function s.gcheck(g)
	return g:GetSum(Card.GetBaseAttack)>0
end
-- ②效果的对象选择处理：检索自己场上满足条件的「反叛曲机器人」怪兽，发动条件为其中存在原本攻击力合计大于0的任意数量组合；让玩家选择任意数量为对象，设置回手卡和回复基本分的操作信息及回复数值
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检索自己怪兽区域所有满足条件的表侧表示「反叛曲机器人」怪兽
	local tg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_MZONE,0,nil,e)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return tg:CheckSubGroup(s.gcheck,1,99) end
	-- 向玩家发送"请选择要返回手牌的卡"的选择提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local g=tg:SelectSubGroup(tp,s.gcheck,false,1,99)
	-- 设置连锁操作信息：预定将所选的怪兽组回到手卡·额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
	-- 将所选怪兽组设置为当前连锁的效果对象
	Duel.SetTargetCard(g)
	-- 将所选怪兽的原本攻击力合计数值记录为连锁的对象参数
	Duel.SetTargetParam(g:GetSum(Card.GetBaseAttack))
	-- 设置连锁操作信息：预定使自己回复等于所选怪兽原本攻击力合计数值的基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetSum(Card.GetBaseAttack))
end
-- 手卡特殊召唤过滤函数：检查卡为「反叛曲机器人」怪兽且可以被此效果特殊召唤
function s.spfilter2(c,e,tp)
	return c:IsSetCard(0x1cf)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的处理：回复对象怪兽原本攻击力合计数值的基本分并将其回到手卡·额外卡组；若有卡实际回到手卡或额外卡组、自己场上有空格且手卡存在可特殊召唤的「反叛曲机器人」怪兽，则询问玩家，玩家同意时选择手卡1只该系列怪兽，在回复与回手卡处理之后将其特殊召唤
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得与当前连锁相关的所有效果对象卡
	local g=Duel.GetTargetsRelateToChain()
	-- 若对象存在，则使自己回复那些怪兽原本攻击力合计数值的基本分，且实际回复值不为0
	if g:GetCount()>0 and Duel.Recover(tp,g:GetSum(Card.GetBaseAttack),REASON_EFFECT)~=0
		-- 并且将那些怪兽回到持有者的手卡·额外卡组，且实际有卡被操作
		and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
		-- 取得上一步送回手卡·额外卡组操作中实际被操作的卡片组
		local og=Duel.GetOperatedGroup()
		if og:IsExists(Card.IsLocation,1,nil,LOCATION_HAND+LOCATION_EXTRA)
			-- 并且自己场上存在1个及以上可用的主要怪兽区空格
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 并且自己手卡存在至少1只可以被特殊召唤的「反叛曲机器人」怪兽
			and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND,0,1,nil,e,tp)
			-- 并询问玩家是否要从手卡特殊召唤（玩家选择"是"才继续）
			and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否从手卡特殊召唤？"
			-- 向玩家发送"请选择要特殊召唤的卡"的选择提示
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 让玩家从自己手卡选择1只「反叛曲机器人」怪兽
			local sg=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_HAND,0,1,1,nil,e,tp)
			if sg:GetCount()>0 then
				-- 中断当前效果处理，使之后的特殊召唤与之前的回复·回手卡处理视为不同时处理
				Duel.BreakEffect()
				-- 将所选的手卡怪兽以表侧表示特殊召唤到自己场上
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
