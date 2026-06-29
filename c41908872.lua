--覇王眷竜ライトヴルム
-- 效果：
-- ←8 【灵摆】 8→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：怪兽特殊召唤的场合，若自己场上有「霸王龙 扎克」和灵摆怪兽各存在则能发动。这张卡特殊召唤。那之后，可以把在自己场上1只灵摆怪兽和这张卡之内1只的属性·等级变成和另1只相同。
-- 【怪兽效果】
-- 这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从自己的额外卡组（表侧）把1只「霸王眷龙」灵摆怪兽或「霸王门」灵摆怪兽加入手卡。那之后，可以进行1只「霸王眷龙」同调怪兽的同调召唤或者1只「霸王眷龙」超量怪兽的超量召唤。
-- ②：这张卡在额外卡组表侧存在的状态，自己场上的表侧表示的灵摆怪兽被战斗·效果破坏的场合才能发动。这张卡加入手卡。
function c41908872.initial_effect(c)
	-- 向系统登记此卡关联「霸王龙 扎克」（卡片密码：13331639）
	aux.AddCodeList(c,13331639)
	-- 为怪兽卡片启用并注册灵摆卡特有的双向刻度规程
	aux.EnablePendulumAttribute(c)
	-- ①：怪兽特殊召唤的场合，若自己场上有「霸王龙 扎克」和灵摆怪兽存在则能发动。这张卡特殊召唤。那之后，可以把自己场上1只灵摆怪兽和这张卡之内1只的属性·等级变成和另1只相同。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41908872,0))  --"这张卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_ACTIVATE_CONDITION)
	e1:SetCountLimit(1,41908872)
	e1:SetCondition(c41908872.spcon)
	e1:SetTarget(c41908872.sptg)
	e1:SetOperation(c41908872.spop)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从自己的额外卡组（表侧）把1只「霸王眷龙」灵摆怪兽或「霸王门」灵摆怪兽加入手卡。那之后，可以进行1只「霸王眷龙」同调怪兽的同调召唤或者1只「霸王眷龙」超量怪兽的超量召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41908872,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,41908873)
	e2:SetTarget(c41908872.thtg1)
	e2:SetOperation(c41908872.thop1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ②：这张卡在额外卡组表侧表示存在的状态，自己场上的表侧表示的灵摆怪兽被战斗·效果破坏的场合才能发动。这张卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(41908872,2))  --"这张卡加入手卡"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetRange(LOCATION_EXTRA)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,41908874)
	e4:SetCondition(c41908872.thcon2)
	e4:SetTarget(c41908872.thtg2)
	e4:SetOperation(c41908872.thop2)
	c:RegisterEffect(e4)
end
-- 判断自己场上是否存在表侧表示的「霸王龙 扎克」
function c41908872.cfilter1(c,tp)
	return c:IsCode(13331639) and c:IsFaceup()
		-- 且场上同时存在另一只表侧表示的灵摆怪兽
		and Duel.IsExistingMatchingCard(c41908872.cfilter2,tp,LOCATION_MZONE,0,1,c)
end
-- 场上表侧表示存在的灵摆怪兽的过滤条件
function c41908872.cfilter2(c)
	return c:IsType(TYPE_PENDULUM) and c:IsFaceup()
end
-- 判断是否满足怪兽特殊召唤成功且自己场上同时拥有「霸王龙 扎克」和灵摆怪兽的时点
function c41908872.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认上述在场卡片限制条件是否在此刻被完全满足
	return Duel.IsExistingMatchingCard(c41908872.cfilter1,tp,LOCATION_ONFIELD,0,1,nil,tp)
end
-- 灵摆特召效果的发动准备与合法性检查
function c41908872.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息为将处于灵摆区域的此卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 场上除了此卡以外，属性或等级与此卡不同且处于表侧表示的灵摆怪兽的过滤条件
function c41908872.filter(c,ec)
	return c:IsType(TYPE_PENDULUM) and c:IsFaceup() and c:IsLevelAbove(0)
		and (not c:IsAttribute(ec:GetAttribute()) or not c:IsLevel(ec:GetLevel()))
end
-- 特殊召唤处于灵摆区域的此卡以及使自己场上两只怪兽的属性·等级同调一致效果的执行
function c41908872.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 将灵摆区域的此卡以表侧表示特殊召唤到场上
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 获取场上除了此卡以外可用于属性或等级同调的灵摆怪兽
		local g=Duel.GetMatchingGroup(c41908872.filter,tp,LOCATION_MZONE,0,c,c)
		-- 询问玩家是否决定进行后续的属性·等级修改操作
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(41908872,3)) then  --"是否改变怪兽的属性·等级？"
			-- 决定修改时，切断连锁以执行后续动作
			Duel.BreakEffect()
			-- 向玩家发送提示，请选择表侧表示的怪兽以决定同调对象
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
			local rc=g:Select(tp,1,1,c):GetFirst()
			local rg=Group.FromCards(c,rc)
			-- 向玩家提示，请选择要改变属性和等级的这只怪兽
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(41908872,4))  --"请选择要改变的怪兽"
			local sg=rg:Select(tp,1,1,nil)
			-- 在场上高亮显示这只作为修改目标的怪兽
			Duel.HintSelection(sg)
			local tc=sg:GetFirst()
			local sc=(rg-sg):GetFirst()
			-- 注册使选定怪兽的属性变更为另一只怪兽属性的单体持续属性改变效果
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(sc:GetAttribute())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_CHANGE_LEVEL)
			e2:SetValue(sc:GetLevel())
			tc:RegisterEffect(e2)
		end
	end
end
-- 额外卡组表侧表示存在的「霸王眷龙」或「霸王门」灵摆怪兽且能够加入手牌的卡片过滤条件
function c41908872.thfilter(c)
	return c:IsSetCard(0x10f8,0x20f8) and c:IsType(TYPE_PENDULUM) and c:IsFaceup() and c:IsAbleToHand()
end
-- 召唤或特召成功时检索并额外特召效果的发动准备与合法性检查
function c41908872.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组中是否存在符合条件的霸王眷龙或霸王门灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c41908872.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置操作信息为从额外卡组把卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- 额外卡组中处于可以进行同调召唤状态的「霸王眷龙」同调怪兽的过滤条件
function c41908872.scfilter(c)
	return c:IsSetCard(0x20f8) and c:IsSynchroSummonable(nil)
end
-- 额外卡组中处于可以进行超量召唤状态的「霸王眷龙」超量怪兽的过滤条件
function c41908872.xyzfilter(c)
	return c:IsSetCard(0x20f8) and c:IsXyzSummonable(nil)
end
-- 从额外卡组将表侧卡加入手牌以及后续同调/超量召唤操作的执行
function c41908872.thop1(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示，请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从额外卡组表侧卡中选择1只符合条件的怪兽加入手卡
	local tc=Duel.SelectMatchingCard(tp,c41908872.thfilter,tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
	-- 确认卡片成功送入手中，若满足则继续处理后续的额外召唤
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		-- 获取额外卡组中在当前场面上可以直接同调召唤的全部「霸王眷龙」怪兽
		local g1=Duel.GetMatchingGroup(c41908872.scfilter,tp,LOCATION_EXTRA,0,nil)
		-- 获取额外卡组中在当前场面上可以直接超量召唤的全部「霸王眷龙」怪兽
		local g2=Duel.GetMatchingGroup(c41908872.xyzfilter,tp,LOCATION_EXTRA,0,nil)
		if (g1:GetCount()>0 or g2:GetCount()>0)
			-- 询问玩家是否决定立即进行后续的同调召唤或超量召唤
			and Duel.SelectYesNo(tp,aux.Stringid(41908872,5)) then  --"是否同调或超量召唤？"
			-- 选择进行召唤时，切断连锁以执行后续动作
			Duel.BreakEffect()
			local g=g1+g2
			-- 向玩家发送提示，请选择要进行特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sc=g:Select(tp,1,1,nil):GetFirst()
			if g1:IsContains(sc) then
				-- 为选中的同调怪兽举行正规的同调召唤步骤
				Duel.SynchroSummon(tp,sc,nil)
			else
				-- 为选中的超量怪兽举行正规的超量召唤步骤
				Duel.XyzSummon(tp,sc,nil)
			end
		end
	end
end
-- 场上被破坏送去墓地或额外卡组表侧表示的原本属于灵摆怪兽的卡片
function c41908872.thfilter2(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and bit.band(c:GetPreviousTypeOnField(),TYPE_PENDULUM)~=0
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp) and c:IsPreviousPosition(POS_FACEUP)
end
-- 判断此卡是否表侧存在于额外卡组，且场上其他表侧表示灵摆怪兽在此刻被破坏
function c41908872.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return eg:IsExists(c41908872.thfilter2,1,c,tp) and not eg:IsContains(c) and c:IsFaceup()
end
-- 额外回收自身效果的发动准备与合法性检查
function c41908872.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息为将处于额外卡组的此卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 额外回收自身效果的执行
function c41908872.thop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将处于额外卡组表侧表示的此卡加入手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
