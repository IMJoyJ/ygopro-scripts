--スローン・オブ・デーモンズ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，把自己的手卡·额外卡组（表侧）·墓地·除外状态的1只「恶魔」仪式怪兽仪式召唤。
-- ②：自己·对方的准备阶段，自己的额外卡组有表侧的「死亡皇帝恶魔」存在的场合才能发动。墓地·除外状态的这张卡加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 将「死亡皇帝恶魔」的卡片密码加入此卡的关联卡片列表中
	aux.AddCodeList(c,48469380)
	-- ①：等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，把自己的手卡·额外卡组（表侧）·墓地·除外状态的1只「恶魔」仪式怪兽仪式召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己·对方的准备阶段，自己的额外卡组有表侧的「死亡皇帝恶魔」存在的场合才能发动。墓地·除外状态的这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_GRAVE+LOCATION_REMOVED)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：适用于「恶魔」仪式怪兽（若在额外卡组或除外状态则需表侧表示）
function s.rfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsSetCard(0x45)
end
-- 效果①的发动准备与可行性检查
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取玩家当前可用的仪式解放素材
		local mg=Duel.GetRitualMaterial(tp)
		-- 检查手卡·墓地·除外状态·额外卡组是否存在可进行仪式召唤的「恶魔」仪式怪兽
		return Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA,0,1,nil,s.rfilter,e,tp,mg,nil,Card.GetLevel,"Greater")
	end
	-- 设置连锁处理中的操作信息：特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA)
end
-- 效果①的实际处理逻辑
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	-- 获取玩家当前可用的仪式解放素材
	local mg=Duel.GetRitualMaterial(tp)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择1只满足仪式召唤条件的「恶魔」仪式怪兽（受王家长眠之谷影响）
	local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(aux.RitualUltimateFilter),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA,0,1,1,nil,s.rfilter,e,tp,mg,nil,Card.GetLevel,"Greater")
	local tc=tg:GetFirst()
	if tc then
		mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		-- 提示玩家选择要解放的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 设置仪式召唤所需的等级合计检查函数（大于或等于目标怪兽等级）
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Greater")
		-- 让玩家选择满足等级合计要求的解放素材组合
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Greater")
		-- 重置全局附加检查函数
		aux.GCheckAdditional=nil
		if not mat then goto cancel end
		tc:SetMaterial(mat)
		-- 解放选定的仪式素材
		Duel.ReleaseRitualMaterial(mat)
		-- 中断当前效果处理，使后续的特殊召唤不与解放同时处理
		Duel.BreakEffect()
		-- 将仪式怪兽以仪式召唤的方式特殊召唤
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
-- 过滤条件：表侧表示的「死亡皇帝恶魔」
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsCode(48469380)
end
-- 效果②的发动条件检查函数
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的额外卡组是否存在表侧表示的「死亡皇帝恶魔」
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_EXTRA,0,1,nil)
end
-- 效果②的发动准备与可行性检查
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置连锁处理中的操作信息：将这张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果②的实际处理逻辑
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍与连锁相关，且不受王家长眠之谷的影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将这张卡加入手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,c)
	end
end
