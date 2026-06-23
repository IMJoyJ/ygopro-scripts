--カオス・フォーム
-- 效果：
-- ①：等级合计直到变成和仪式召唤的怪兽相同为止，把自己的手卡·场上的怪兽解放或者作为解放的代替而从自己墓地把「青眼白龙」或「黑魔术师」除外，从手卡把1只「混沌」仪式怪兽仪式召唤。
function c21082832.initial_effect(c)
	-- 记录该卡片效果中涉及的「青眼白龙」和「黑魔术师」的卡片编号
	aux.AddCodeList(c,46986414,89631139)
	-- 为该卡片添加仪式召唤效果，要求仪式怪兽的等级与解放或除外的素材等级总和相等
	aux.AddRitualProcEqual2(c,c21082832.filter,nil,c21082832.mfilter)
end
-- 过滤手卡或场上的怪兽，确保其为「混沌」系列怪兽
function c21082832.filter(c,e,tp,m1,m2,ft)
	return c:IsSetCard(0xcf)
end
-- 过滤墓地中的怪兽，确保其为「青眼白龙」或「黑魔术师」
function c21082832.mfilter(c)
	return c:IsCode(46986414,89631139)
end
