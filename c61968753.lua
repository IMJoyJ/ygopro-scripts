--バブル・シャッフル
-- 效果：
-- 「元素英雄 水泡侠」在场上表侧表示存在时才能发动。自己场上表侧攻击表示存在的1只「元素英雄 水泡侠」和对方场上表侧攻击表示存在的1只怪兽变成守备表示。把变成守备表示的1只「元素英雄 水泡侠」作为祭品，从手卡特殊召唤1只名字带有「元素英雄」的怪兽。
function c61968753.initial_effect(c)
	-- 将卡片关联到「元素英雄」怪兽系列列表中，以便进行系列判定
	aux.AddSetNameMonsterList(c,0x3008)
	-- 「元素英雄 水泡侠」在场上表侧表示存在时才能发动。自己场上表侧攻击表示存在的1只「元素英雄 水泡侠」和对方场上表侧攻击表示存在的1只怪兽变成守备表示。把变成守备表示的1只「元素英雄 水泡侠」作为祭品，从手卡特殊召唤1只名字带有「元素英雄」的怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c61968753.postg)
	e1:SetOperation(c61968753.posop)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧攻击表示、可以改变表示形式、卡名为「元素英雄 水泡侠」且可以被效果解放的怪兽
function c61968753.filter1(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition() and c:IsCode(79979666) and c:IsReleasableByEffect()
end
-- 过滤对方场上表侧攻击表示且可以改变表示形式的怪兽
function c61968753.filter2(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition()
end
-- 过滤手卡中属于「元素英雄」系列且可以特殊召唤的怪兽
function c61968753.spfilter(c,e,tp)
	return c:IsSetCard(0x3008) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的靶向与合法性检测函数，判断是否满足发动条件并选择对象
function c61968753.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在符合条件的表侧攻击表示「元素英雄 水泡侠」
	if chk==0 then return Duel.IsExistingTarget(c61968753.filter1,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在符合条件的表侧攻击表示怪兽
		and Duel.IsExistingTarget(c61968753.filter2,tp,0,LOCATION_MZONE,1,nil)
		-- 检查自己场上的怪兽区域是否有空位（因为要解放1只怪兽并特殊召唤1只，所以可用格子数大于等于0即可，即解放前格子数大于-1）
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手卡中是否存在可以特殊召唤的「元素英雄」怪兽
		and Duel.IsExistingMatchingCard(c61968753.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择自己场上1只表侧攻击表示的「元素英雄 水泡侠」作为效果对象
	local g1=Duel.SelectTarget(tp,c61968753.filter1,tp,LOCATION_MZONE,0,1,1,nil)
	e:SetLabelObject(g1:GetFirst())
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择对方场上1只表侧攻击表示的怪兽作为效果对象
	local g2=Duel.SelectTarget(tp,c61968753.filter2,tp,0,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
	-- 设置效果处理信息：包含改变2张卡表示形式的操作
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g1,2,0,0)
	-- 设置效果处理信息：包含从手卡特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 过滤仍与当前效果相关且处于表侧攻击表示的对象怪兽
function c61968753.pfilter(c,e)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsRelateToEffect(e)
end
-- 效果处理函数，执行改变表示形式、解放水泡侠并特殊召唤手卡「元素英雄」怪兽的具体流程
function c61968753.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关的表侧攻击表示的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c61968753.pfilter,nil,e)
	-- 如果两个对象都存在，则将它们全部变成表侧守备表示
	if g:GetCount()==2 and Duel.ChangePosition(g,POS_FACEUP_DEFENSE)~=0 then
		local tc=e:GetLabelObject()
		if not tc:IsImmuneToEffect(e) and tc:IsReleasableByEffect() then
			-- 阶段性中断效果，使后续的解放和特殊召唤处理与改变表示形式不视为同时进行
			Duel.BreakEffect()
			-- 将变成守备表示的「元素英雄 水泡侠」解放，若解放失败或此时自己场上没有空余怪兽区域，则结束效果
			if Duel.Release(tc,REASON_EFFECT)==0 or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从手卡选择1只满足条件的「元素英雄」怪兽
			local sg=Duel.SelectMatchingCard(tp,c61968753.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
			if sg:GetCount()>0 then
				-- 阶段性中断效果，使后续的特殊召唤与解放不视为同时进行
				Duel.BreakEffect()
				-- 将选择的「元素英雄」怪兽在自己场上表侧表示特殊召唤
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
